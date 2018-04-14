/*
MIT License

Copyright (c) 2018 Clipsey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
module wereshift.gameobjects.villager;
import wereshift.gameobjects;
import wereshift.gameobject;
import wereshift.animation;
import wereshift.game;
import wereshift.text;
import wereshift.random;

import std.stdio;

public enum VillagerGender {
	Male,
	Female
}

public enum VillagerType {
	Citizen,
	TownCrier,
	Guard,
	Hunter,
	Rifleman
}

public enum VillagerAIState {
	Idle,
	Moving,
	Suspicious,
	InDanger
}

public enum VillagerAIMoveDirection {
	Left,
	Right
}

public class Villager : GameObject {
	// Looks
	public static Texture2D VillagerMaleTex = null;
	public static Texture2D VillagerFemaleTex = null;

	public static Texture2D VillagerMaleHunterTex = null;
	public static Texture2D VillagerMaleCrierTex = null;
	public static Texture2D VillagerMaleGuardTex = null;
	private static Text villager_exclaim;
	private Color villager_draw_color;

	private static Random rng = null;

	public Animation VillagerAnimation;
	public VillagerGender Gender;

	private Vector2i render_bounds;

	private SpriteFlip flip = SpriteFlip.None;

	// Movement
	public Vector2 Position;

	private float speed = 3f;
	private float panic_boost = 2f;

	private float knockback_speed = 15f;
	private float knockback_velocity = 0f;
	private float knockback_drag = .90f;

	private float knockback_power_wolf = 2f;
	private float knockback_power_werewolf = 3f;

	private int stun_frame = 0;
	private int stun_frames = 100;

	// AI Actions
	public VillagerType AIType = VillagerType.Citizen;
	public VillagerAIState AIState;
	public VillagerAIMoveDirection AIMoveState = VillagerAIMoveDirection.Left;
	private int decision_timer = 0;
	private int decision_timeout = 500;
	private float werewolf_panic_dist = 600f;
	private bool has_been_attacked_by_wolf = false;
	private bool has_seen_player_transform = false;

	private int p_attack_timeout = 0;
	private int p_attack_timeout_m = 150;

	public Rectangle Hitbox;
	private int health = 100;
	private int defense = 1;

	private bool in_house = false;

	public bool CanEnterHouse() {
		if (knockback_velocity != 0) return false;
		if (stun_frame != 0) return false;
		return true;
	}

	this(Level parent, Vector2 spawnpoint, VillagerType type) {
		super(parent, spawnpoint);

		if (rng is null) rng = new Random();

		this.Position = spawn_point;
		
		// it seemed to prefer female wayyyyyyy over male, this seems to balance it out pretty well.
		if (rng.Next(0, 100) >= 45) {
			Gender = VillagerGender.Male;
		} else {
			Gender = VillagerGender.Female;
		}
		
		// TODO: Add random defense for NPC, based on their weapons, etc.

		this.AIState = VillagerAIState.Idle;
		this.AIType = type;
	}

	public bool Damage(Form player_form, float player_velocity, int damage) {

		// I mean, how would you hurt an NPC hiding inside a house?
		if (in_house) return false;

		// You can't damage an NPC being stunned
		if (stun_frame > 0) return false;

		// You can also not damage an NPC being knocked back.
		if (knockback_velocity != 0) return false;

		// Simple damage formular
		this.health -= damage/defense;

		// default knockback
		float knockback = knockback_speed*knockback_power_wolf;

		// Knockback harder if werewolf.
		if (player_form == Form.Werewolf) {
			knockback = knockback_speed*knockback_power_werewolf;
		} else {
			// Also if wolf, tell the villager they've been hurt by a wolf
			has_been_attacked_by_wolf = true;
		}

		// Knockback directions.
		if (player_velocity >= 0)
			knockback_velocity = knockback;
		else
			knockback_velocity = -knockback;

		if (health <= 0) {
			foreach(GameObject villager; parent.Entities) {
				Villager v = (cast(Villager)villager);
				if (v.same_direction_as(parent.ThePlayer.Position) && v.Hitbox.Center.Distance(parent.ThePlayer.Hitbox.Center) < 600f) {
					v.AIState = VillagerAIState.InDanger;
				}
			}
			this.Alive = false;
			if (!WereshiftGame.GoreOn) {
				parent.ThePlayer.KillSucceeded();
			}
		}
		return true;
	}

	public override void LoadContent(ContentManager content) {
		if (VillagerMaleTex is null)
			VillagerMaleTex = content.LoadTexture("entities/m_villager");

		if (VillagerMaleCrierTex is null)
			VillagerMaleCrierTex = content.LoadTexture("entities/m_villager_crier");

		if (VillagerMaleHunterTex is null)
			VillagerMaleHunterTex = content.LoadTexture("entities/m_villager_hunter");

		if (VillagerMaleGuardTex is null)
			VillagerMaleGuardTex = content.LoadTexture("entities/m_villager_guard");

		if (VillagerFemaleTex is null)
			VillagerFemaleTex = content.LoadTexture("entities/f_villager");

		if (villager_exclaim is null)
			villager_exclaim = new Text(content, "fonts/shramp_sans");

		render_bounds = Vector2i(VillagerFemaleTex.Width/8, VillagerFemaleTex.Height/6);
		this.Position -= Vector2(0f, render_bounds.Y);
		VillagerAnimation = new Animation([
			"dark_idle": [
				new AnimationData(0, 0, 10),
				new AnimationData(1, 0, 10),
				new AnimationData(2, 0, 10),
				new AnimationData(3, 0, 10)
			],
			"dark_walk": [
				new AnimationData(0, 1, 10),
				new AnimationData(1, 1, 10),
				new AnimationData(2, 1, 10),
				new AnimationData(3, 1, 10),
				new AnimationData(4, 1, 10),
				new AnimationData(5, 1, 10),
				new AnimationData(6, 1, 10),
				new AnimationData(7, 1, 10)
			],
			"dark_panic": [
				new AnimationData(0, 2, 10),
				new AnimationData(1, 2, 10),
				new AnimationData(2, 2, 10),
				new AnimationData(3, 2, 10),
				new AnimationData(4, 2, 10),
				new AnimationData(5, 2, 10),
				new AnimationData(6, 2, 10),
				new AnimationData(7, 2, 10)
			],
			"light_idle": [
				new AnimationData(0, 3, 10),
				new AnimationData(1, 3, 10),
				new AnimationData(2, 3, 10),
				new AnimationData(3, 3, 10)
			],
			"light_walk": [
				new AnimationData(0, 4, 10),
				new AnimationData(1, 4, 10),
				new AnimationData(2, 4, 10),
				new AnimationData(3, 4, 10),
				new AnimationData(4, 4, 10),
				new AnimationData(5, 4, 10),
				new AnimationData(6, 4, 10),
				new AnimationData(7, 4, 10)
			],
			"light_panic": [
				new AnimationData(0, 5, 10),
				new AnimationData(1, 5, 10),
				new AnimationData(2, 5, 10),
				new AnimationData(3, 5, 10),
				new AnimationData(4, 5, 10),
				new AnimationData(5, 5, 10),
				new AnimationData(6, 5, 10),
				new AnimationData(7, 5, 10)
			]
		]);
		VillagerAnimation.ChangeAnimation("light_idle");
		villager_draw_color = new Color(255, 255, 255, 255);
		this.Hitbox = new Rectangle(cast(int)this.Position.X, cast(int)this.Position.Y, cast(int)render_bounds.X, cast(int)render_bounds.Y);
	}

	public override void Update(GameTimes game_time) {
		if (in_house) return;
		this.Hitbox = new Rectangle(cast(int)this.Position.X+140, cast(int)this.Position.Y, 40, cast(int)render_bounds.Y);

		if (health <= 0) {
			// The NPC dead, remove from memory asap.

			if (!WereshiftGame.GoreOn) {
				// If the player prefers no gore, just make the villagers into spoopy ghost that flies offscreen.
				villager_draw_color.Alpha = cast(int)(128);

				this.Position -= Vector2(0, 4f);
			} else {
				// Gore the heck of of this.

			}
			// TODO: get level to dispose of corpse.

			VillagerAnimation.Update();
			return;
		}

		if (stun_frame >= 1) {
			// NPC sprite should be "fallen"
			VillagerAnimation.ChangeAnimation("light_idle", true);

			// The NPC is stunned, update here instead to do some color stuff.
			knockback_velocity = 0f;

			villager_draw_color.Alpha = (cast(int)((Mathf.Sin(game_time.TotalTime.Milliseconds/64)/2)+1)*255);

			stun_frame--;
			VillagerAnimation.Update();
			return;
		}

		// Reset the transparency of the NPC if it's not the right value.
		if (villager_draw_color.Alpha != 255)
			villager_draw_color.Alpha = 255;

		// Handle NPC ticks and knockback behaviour
		if (knockback_velocity == 0)
			handle_npc_behaviour();
		else
			handle_npc_knockback_behaviour();

		// Handle NPCs straying too far from home.
		// Except, if in danger, don't care if they run away from home
		if (this.AIState != VillagerAIState.InDanger) handle_straying();

		int tm = decision_timeout;

		// Panics last twice as long.
		if (this.AIState == VillagerAIState.InDanger) tm *= 10;

		// Timeout between NPC decisions.
		if (decision_timer >= tm) {
			decision_timer = 0;
			this.AIState = cast(VillagerAIState)rng.Next(0, 2);
			
			this.AIMoveState = cast(VillagerAIMoveDirection)rng.Next(0, 2);
			HandleFlip(this.AIMoveState);
			decision_timeout = rng.Next(30, 150);
		}

		decision_timer++;
		VillagerAnimation.Update();
	}

	public void UpdatePlayerKnowledgeState(bool has_transformed) {
		// Check if player is transforming
		set_player_transform_knowledge(has_transformed);
	}

	private void set_player_transform_knowledge(bool transform) {
		if (same_direction_as(parent.ThePlayer.Hitbox.Center)) {
			if (this.Hitbox.Center.Distance(parent.ThePlayer.Hitbox.Center) < 600f) {
				if (transform) has_seen_player_transform = true;
			}
		}
	}

	// HANDLE SUSPICIOUS AISTATE
	private void handle_npc_suspic_behaviour() {
		if (has_seen_player_transform) this.AIState = VillagerAIState.InDanger;
	}

	// HANDLE INDANGER AISTATE
	private bool has_started_stabbing = false;
	private void handle_npc_danger_behaviour() {
		if (AIType == VillagerType.Citizen || AIType == VillagerType.TownCrier) {
			// Villager is a wimp and panicking.
			VillagerAnimation.ChangeAnimation("light_panic", true);

			// Run away from the player
			if (parent.ThePlayer.Hitbox.Center.X > this.Hitbox.Center.X)
				this.AIMoveState = VillagerAIMoveDirection.Left;

			if (parent.ThePlayer.Hitbox.Center.X < this.Hitbox.Center.X)
				this.AIMoveState = VillagerAIMoveDirection.Right;


			// Apply move direction.
			MoveDirection(this.AIMoveState);

			// tell the player that THEY HAVE BEEN SEEN.
			parent.ThePlayer.SeePlayer();

			// Share the panic/in danger state with fellow villagers if you meet them.
			foreach(GameObject other_villager; parent.Entities) {
				if (other_villager != this) {
					if ((cast(Villager)other_villager).Hitbox.Intersects(this.Hitbox)) {
						(cast(Villager)other_villager).AIState = VillagerAIState.InDanger;
					}
				}
			}
		} else {
			// The villager is *not* a wimp AND WANTS TO BATTLE!

			if (AIType == VillagerType.Guard) {
				if (p_attack_timeout == 0) {
					if (this.Hitbox.Center.Distance(parent.ThePlayer.Hitbox.Center) > 32f) {
						VillagerAnimation.ChangeAnimation("light_walk", true);

						// Run thowards from the player
						if (parent.ThePlayer.Hitbox.Center.X > this.Hitbox.Center.X)
							this.AIMoveState = VillagerAIMoveDirection.Right;

						if (parent.ThePlayer.Hitbox.Center.X < this.Hitbox.Center.X)
							this.AIMoveState = VillagerAIMoveDirection.Left;
						
						// Apply move direction.
						MoveDirection(this.AIMoveState);

						// tell the player that THEY HAVE BEEN SEEN.
						parent.ThePlayer.SeePlayer();

						// Share the panic/in danger state with fellow villagers if you meet them.
						foreach(GameObject other_villager; parent.Entities) {
							if (other_villager != this) {
								if ((cast(Villager)other_villager).Hitbox.Intersects(this.Hitbox)) {
									(cast(Villager)other_villager).AIState = VillagerAIState.InDanger;
								}
							}
						}
					} else {
						// If close enough, stab.
						if (!has_started_stabbing) VillagerAnimation.ChangeAnimation("light_panic");
						has_started_stabbing = true;
						if (VillagerAnimation.IsLastFrame) {
							parent.ThePlayer.Damage(10);
							p_attack_timeout = p_attack_timeout_m;
							has_started_stabbing = false;
						}

						// tell the player that THEY HAVE BEEN SEEN.
						parent.ThePlayer.SeePlayer();
					}
				} else {
					VillagerAnimation.ChangeAnimation("light_walk", true);

					// Run away from the player
					if (parent.ThePlayer.Hitbox.Center.X > this.Hitbox.Center.X)
						this.AIMoveState = VillagerAIMoveDirection.Left;

					if (parent.ThePlayer.Hitbox.Center.X < this.Hitbox.Center.X)
						this.AIMoveState = VillagerAIMoveDirection.Right;


					// Apply move direction.
					MoveDirection(this.AIMoveState);

					// tell the player that THEY HAVE BEEN SEEN.
					parent.ThePlayer.SeePlayer();
					p_attack_timeout--;

					// Share the panic/in danger state with fellow villagers if you meet them.
					foreach(GameObject other_villager; parent.Entities) {
						if (other_villager != this) {
							if ((cast(Villager)other_villager).Hitbox.Intersects(this.Hitbox)) {
								(cast(Villager)other_villager).AIState = VillagerAIState.InDanger;
							}
						}
					}
				}
			} else if (AIType == VillagerType.Hunter) {


				if (p_attack_timeout == 0) {
					if (this.Hitbox.Center.Distance(parent.ThePlayer.Hitbox.Center) > 512f) {
						VillagerAnimation.ChangeAnimation("light_walk", true);

						// Run thowards from the player
						if (parent.ThePlayer.Hitbox.Center.X > this.Hitbox.Center.X)
							this.AIMoveState = VillagerAIMoveDirection.Right;

						if (parent.ThePlayer.Hitbox.Center.X < this.Hitbox.Center.X)
							this.AIMoveState = VillagerAIMoveDirection.Left;
						
						// Apply move direction.
						MoveDirection(this.AIMoveState);

						// tell the player that THEY HAVE BEEN SEEN.
						parent.ThePlayer.SeePlayer();

						// Share the panic/in danger state with fellow villagers if you meet them.
						foreach(GameObject other_villager; parent.Entities) {
							if (other_villager != this) {
								if ((cast(Villager)other_villager).Hitbox.Intersects(this.Hitbox)) {
									(cast(Villager)other_villager).AIState = VillagerAIState.InDanger;
								}
							}
						}
					} else {
						// If close enough, fire arrow.
						if (!has_started_stabbing) VillagerAnimation.ChangeAnimation("light_panic");
						has_started_stabbing = true;
						if (VillagerAnimation.IsLastFrame) {
							// TODO: Spawn projectile in direction of player
							Vector2 vel = (this.Hitbox.Center+parent.ThePlayer.Hitbox.Center);
							vel = Vector2(vel.X, -(rng.Next(512, 2048)));
							vel = vel.Normalize*10;

							if (parent.ThePlayer.Hitbox.Center.X < this.Hitbox.Center.X) vel.X = -vel.X;

							Projectile p = new Projectile(parent, this.Hitbox.Center, ProjectileType.Arrow, vel*2);
							p.LoadContent(parent.Content);
							parent.Projectiles ~= p;
							
							//parent.ThePlayer.Damage(10);
							p_attack_timeout = p_attack_timeout_m/2;
							has_started_stabbing = false;
						}

						// tell the player that THEY HAVE BEEN SEEN.
						parent.ThePlayer.SeePlayer();
					}
				} else {
					VillagerAnimation.ChangeAnimation("light_walk", true);

					// Run away from the player
					if (parent.ThePlayer.Hitbox.Center.X > this.Hitbox.Center.X)
						this.AIMoveState = VillagerAIMoveDirection.Left;

					if (parent.ThePlayer.Hitbox.Center.X < this.Hitbox.Center.X)
						this.AIMoveState = VillagerAIMoveDirection.Right;


					// Apply move direction.
					MoveDirection(this.AIMoveState);

					// tell the player that THEY HAVE BEEN SEEN.
					parent.ThePlayer.SeePlayer();
					p_attack_timeout--;

					// Share the panic/in danger state with fellow villagers if you meet them.
					foreach(GameObject other_villager; parent.Entities) {
						if (other_villager != this) {
							if ((cast(Villager)other_villager).Hitbox.Intersects(this.Hitbox)) {
								(cast(Villager)other_villager).AIState = VillagerAIState.InDanger;
							}
						}
					}
				}
			}
		}
	}

	// HANDLE KNOCKBACK BEHAVIOUR
	private void handle_npc_knockback_behaviour() {
		// NPC sprite should be "fallen"
		VillagerAnimation.ChangeAnimation("light_idle", true);
		// TODO: Hurt frames
		if (Mathf.Abs(knockback_velocity) * knockback_drag <= knockback_drag) {
			stun_frame = stun_frames;
		}

		this.Position += Vector2(knockback_velocity, 0f);

		// Reduce knockback speed overtime by drag.
		knockback_velocity *= knockback_drag;

		// Once the npc gets back up PANIC!
		this.AIState = VillagerAIState.InDanger;
		decision_timer = 0;
	}

	private bool same_direction_as(Vector2 dir) {
		if (dir.X < this.Hitbox.Center.X && this.AIMoveState == VillagerAIMoveDirection.Left) return true;
		if (dir.X >= this.Hitbox.Center.X && this.AIMoveState == VillagerAIMoveDirection.Right) return true;
		return false;
	}

	private void handle_npc_behaviour() {
		VillagerAnimation.ChangeAnimation("light_idle", true);

		// InDanger.
		if (this.Position.Distance(parent.ThePlayer.Position) < werewolf_panic_dist) {
			if (parent.ThePlayer.CurrentForm == Form.Werewolf && this.AIState != VillagerAIState.InDanger) {
				// Check if the villager is looking at the player.
				if (same_direction_as(parent.ThePlayer.Hitbox.Center)) {
					decision_timer = 0;
					this.AIState = VillagerAIState.InDanger;
				}
			}
		}

		if (this.Position.Distance(parent.ThePlayer.Position) < werewolf_panic_dist/2) {
			if (parent.ThePlayer.CurrentForm == Form.Wolf) {
				// Check if the villager is looking at the player.
				if (same_direction_as(parent.ThePlayer.Hitbox.Center)) {
					decision_timer = 0;
					this.AIState = VillagerAIState.Suspicious;
					if (has_been_attacked_by_wolf || has_seen_player_transform) this.AIState = VillagerAIState.InDanger;
				}
			}
		}

		if (this.AIState == VillagerAIState.InDanger) {
			handle_npc_danger_behaviour();
		}

		if (this.AIState == VillagerAIState.Suspicious) {
			handle_npc_suspic_behaviour();
		}
	}

	private void handle_straying() {
		if (this.AIState == VillagerAIState.Moving) {
			VillagerAnimation.ChangeAnimation("light_walk", true);
			MoveDirection(this.AIMoveState);

			// If the villager strays too far from home, go back home.
			if (this.Position.Distance(this.spawn_point) > 2000f) {
				if (this.Position.X < spawn_point.X) {
					this.AIMoveState = VillagerAIMoveDirection.Right;

				} else if (this.Position.X > spawn_point.X) {
					this.AIMoveState = VillagerAIMoveDirection.Left;

				}
				MoveDirection(this.AIMoveState);
			}
		}
	}

	public void HandleFlip(VillagerAIMoveDirection direction) {
		if (direction == VillagerAIMoveDirection.Right) {
			this.flip = SpriteFlip.None;
			return;
		}
		this.flip = SpriteFlip.FlipVertical;
	}

	public void MoveDirection(VillagerAIMoveDirection direction) {
		float move_speed = speed;
		// If the villager is in panic, add a little speed boost.
		if (this.AIState == VillagerAIState.InDanger)
			move_speed += panic_boost;
		
		// Move in specified direction
		if (direction == VillagerAIMoveDirection.Right) this.Position += Vector2(move_speed, 0f);
		else this.Position -= Vector2(move_speed, 0f);

		HandleFlip(direction);
	}

	public void EnterHouse() {
		in_house = true;
	}

	public void LeaveHouse() {
		in_house = false;
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		if (in_house) return;
		sprite_batch.Draw(parent.BoxTex, Hitbox, new Rectangle(0, 0, 1, 1), Color.Yellow, flip);

		if (has_seen_player_transform) {
			Vector2 mes = villager_exclaim.MeasureString("!", 2f);
			villager_exclaim.DrawString(sprite_batch, "!", Vector2(this.Hitbox.Center.X-(mes.X/2), this.Hitbox.Y - 8 - mes.Y), 2f, Color.Red);
		}
		if (this.AIState == VillagerAIState.Suspicious) {
			Vector2 mes = villager_exclaim.MeasureString("?", 2f);
			villager_exclaim.DrawString(sprite_batch, "?", Vector2(this.Hitbox.Center.X-(mes.X/2), this.Hitbox.Y - 8 - mes.Y), 2f, Color.Yellow);
		}

		if (AIType == VillagerType.Citizen) {
			if (Gender == VillagerGender.Female) 
				sprite_batch.Draw(VillagerFemaleTex, 
					new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
					new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
					villager_draw_color,
					flip);

			if (Gender == VillagerGender.Male) 
				sprite_batch.Draw(VillagerMaleTex,
					new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
					new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
					villager_draw_color,
					flip);
		} else {
			if (AIType == VillagerType.TownCrier)
				sprite_batch.Draw(VillagerMaleCrierTex,
					new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
					new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
					villager_draw_color,
					flip);
			if (AIType == VillagerType.Hunter)
				sprite_batch.Draw(VillagerMaleHunterTex,
					new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
					new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
					villager_draw_color,
					flip);
			if (AIType == VillagerType.Guard)
				sprite_batch.Draw(VillagerMaleGuardTex,
						new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
						new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
						villager_draw_color,
						flip);
		}
	}
}