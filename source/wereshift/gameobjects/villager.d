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
import wereshift.random;

import std.stdio;

public class VillagerFactory : GameObjectFactory {
	public override GameObject Construct(Level l, Vector2 spawnpoint) {
		return new Villager(l, spawnpoint);
	}
}

public enum VillagerGender {
	Male,
	Female
}

public enum PanicType {
	WerewolfSeen,
	WolfSeen,
	WolfBitten,
	WerewolfAttacked,

	// Boundary for panic types.
	DankMemes
}

public enum VillagerAIState {
	Idle,
	Moving,
	Attacking,
	Panicking
}

public enum VillagerAIMoveDirection {
	Left,
	Right
}

public class Villager : GameObject {
	// Looks
	public static Texture2D VillagerMaleTex = null;
	public static Texture2D VillagerFemaleTex = null;
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

	private float knockback_speed = 10f;
	private float knockback_velocity = 0f;
	private float knockback_drag = .90f;

	private float knockback_power_wolf = 2f;
	private float knockback_power_werewolf = 3f;

	private int stun_frame = 0;
	private int stun_frames = 100;

	// AI Actions
	private VillagerAIState AIState;
	private VillagerAIMoveDirection AIMoveState = VillagerAIMoveDirection.Left;
	private int decision_timer = 0;
	private int decision_timeout = 500;
	private float werewolf_panic_dist = 1000f;

	public Rectangle Hitbox;
	private int health = 100;
	private int defense = 1;

	this(Level parent, Vector2 spawnpoint) {
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
	}

	public bool Damage(Form player_form, float player_velocity, int damage) {

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
		}

		// Knockback directions.
		if (player_velocity >= 0)
			knockback_velocity = knockback;
		else
			knockback_velocity = -knockback;
		return true;
	}

	public override void LoadContent(ContentManager content) {
		if (VillagerMaleTex is null)
			VillagerMaleTex = content.LoadTexture("entities/m_villager");	
		if (VillagerFemaleTex is null)
			VillagerFemaleTex = content.LoadTexture("entities/f_villager");

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
		this.Hitbox = new Rectangle(cast(int)this.Position.X, cast(int)this.Position.Y, cast(int)render_bounds.X, cast(int)render_bounds.Y);

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

			villager_draw_color.Alpha = (cast(int)((Mathf.Sin(game_time.TotalTime.Seconds)/2)+1)*255);

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
		handle_straying();

		// Timeout between NPC decisions.
		if (decision_timer >= decision_timeout) {
			decision_timer = 0;
			this.AIState = cast(VillagerAIState)rng.Next(0, 3);
			
			this.AIMoveState = cast(VillagerAIMoveDirection)rng.Next(0, 2);
			HandleFlip(this.AIMoveState);
			decision_timeout = rng.Next(30, 150);
		}

		decision_timer++;
		VillagerAnimation.Update();
	}

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
	}

	private void handle_npc_behaviour() {
		VillagerAnimation.ChangeAnimation("light_idle", true);
		if (this.Position.Distance(parent.ThePlayer.Position) < werewolf_panic_dist) {
			if (parent.ThePlayer.CurrentForm == Form.Werewolf) {
				this.AIState = VillagerAIState.Panicking;
			}
		}

		if (this.Position.Distance(parent.ThePlayer.Position) < werewolf_panic_dist/2) {
			if (parent.ThePlayer.CurrentForm == Form.Wolf) {
				this.AIState = VillagerAIState.Panicking;
			}
		}

		if (this.AIState == VillagerAIState.Panicking) {
			if (this.Position.Distance(parent.ThePlayer.Position) < 1000f) {
				VillagerAnimation.ChangeAnimation("light_panic", true);

				if (this.Position.X < spawn_point.X) {
					this.AIMoveState = VillagerAIMoveDirection.Right;

				} else if (this.Position.X > spawn_point.X) {
					this.AIMoveState = VillagerAIMoveDirection.Left;

				}
				MoveDirection(this.AIMoveState);
				parent.ThePlayer.SeePlayer();

				// TODO: Make them enter the first available house, and/or notify other villagers.

			} else {
				// It's out of harm's way for now, let it decide something else to do.
				decision_timer = decision_timeout;
			}
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
		if (this.AIState == VillagerAIState.Panicking)
			move_speed += panic_boost;
		
		// Move in specified direction
		if (direction == VillagerAIMoveDirection.Right) this.Position += Vector2(move_speed, 0f);
		else this.Position -= Vector2(move_speed, 0f);

		HandleFlip(direction);
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
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
	}
}