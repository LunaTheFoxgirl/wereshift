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
module wereshift.gameobjects.player;
import wereshift.gameobjects;
import wereshift.gameobject;
import wereshift.animation;
import wereshift.game;
import std.string;

// Debugging
import std.stdio;

public enum Form {
	Werewolf,
	Wolf,
	Human
}

public enum HideState {
	Exposed,
	Hidden
}

public class Player : GameObject {
	// Looks
	private Texture2D player_tex;
	private Animation player_anim;
	private SpriteFlip flip = SpriteFlip.None;

	// Movement
	private bool is_crouching = false;
	private bool is_grounded = true;

	private float speed = 4f;
	private float werewolf_boost = 2f;
	private float wolf_boost = 5.6f;
	private float sneak_slowdown = 2f;
	
	public Vector2 Position = Vector2(0f, 0f);
	public float Gravity = 0.2f;
	private float y_velocity = 0f;
	private float x_velocity = 0f;
	private float jump_velocity = 5f;

	// Collission
	public Rectangle Hitbox;

	// Forms
	public Form CurrentForm = Form.Wolf;
	private int transform_counter = 0;
	private int transform_max = 50;
	private bool allow_transform = true;

	// Stealth
	public HideState HiddenState = HideState.Hidden;
	public LightState LightingState = LightState.InShade;
	private int watchers = 0;
	private int shaders = 0;

	public void SeePlayer() {
		watchers++;
		HiddenState = HideState.Exposed;
	}

	public void ForgetPlayer() {
		watchers--;
	}

	public void Shade() {
		shaders++;
	}

	//Health
	private float health = 100f;
	private float defense = 10f;
	private float overtime_damage = .005f;

	public float Health() {
		return health;
	}

	public void Damage(int amount) {
		health -= amount/defense;
	}

	// Constructor

	this(Level parent) {
		super(parent, Vector2(0, 0));
		this.Position = spawn_point;
	}

	// Overrides

	public override void LoadContent(ContentManager content) {
		player_tex = content.LoadTexture("entities/player");

		player_anim = new Animation([
			"human_idle": [
				new AnimationData(0, 0, 10),
				new AnimationData(1, 0, 10),
				new AnimationData(2, 0, 10),
				new AnimationData(3, 0, 10)
			],
			"human_crouch": [
				new AnimationData(4, 0, 10)
			],
			"human_walk": [
				new AnimationData(0, 1, 10),
				new AnimationData(1, 1, 10),
				new AnimationData(2, 1, 10),
				new AnimationData(3, 1, 10),
				new AnimationData(4, 1, 10),
				new AnimationData(5, 1, 10),
				new AnimationData(6, 1, 10),
				new AnimationData(7, 1, 10)
			],
			"wolf_dark_idle": [
				new AnimationData(0, 2, 20),
				new AnimationData(1, 2, 20),
				new AnimationData(2, 2, 20),
				new AnimationData(3, 2, 20)
			],
			"wolf_dark_crouch": [
				new AnimationData(4, 2, 20)
			],
			"wolf_dark_walk": [
				new AnimationData(0, 3, 11),
				new AnimationData(1, 3, 11),
				new AnimationData(2, 3, 11),
				new AnimationData(3, 3, 11)
			],
			"wolf_dark_jump": [
				new AnimationData(4, 3, 11)
			],
			"wolf_dead": [
				new AnimationData(4, 2, 20)
			],
			"wolf_light_idle": [
				new AnimationData(0, 4, 15),
				new AnimationData(1, 4, 15),
				new AnimationData(2, 4, 15),
				new AnimationData(3, 4, 15)
			],
			"wolf_light_crouch": [
				new AnimationData(4, 4, 15)
			],
			"wolf_light_walk": [
				new AnimationData(0, 5, 10),
				new AnimationData(1, 5, 10),
				new AnimationData(2, 5, 10),
				new AnimationData(3, 5, 10)
			],
			"wolf_light_jump": [
				new AnimationData(4, 5, 10)
			],
			"werewolf_idle": [
				new AnimationData(0, 6, 10),
				new AnimationData(1, 6, 10),
				new AnimationData(2, 6, 10),
				new AnimationData(3, 6, 10),
				new AnimationData(4, 6, 10),
				new AnimationData(5, 6, 10)
			],
			"werewolf_crouch": [
				new AnimationData(6, 6, 10)
			],
			"werewolf_jump": [
				new AnimationData(7, 6, 10)
			],
			"werewolf_walk": [
				new AnimationData(0, 7, 5),
				new AnimationData(1, 7, 5),
				new AnimationData(2, 7, 5),
				new AnimationData(3, 7, 5),
				new AnimationData(4, 7, 5),
				new AnimationData(5, 7, 5),
				new AnimationData(6, 7, 5),
				new AnimationData(7, 7, 5)
			]
		]);
		player_anim.ChangeAnimation("human_idle");

		Position = Vector2(Position.X, -(player_tex.Height/8));
	}

	private MouseState last_state_m;
	private KeyboardState last_state_k;
	private MouseState state_m;
	private KeyboardState state_k;
	public override void Update(GameTimes game_time) {
		state_k = Keyboard.GetState();
		state_m = Mouse.GetState();
		if (last_state_k is null) last_state_k = state_k;
		if (last_state_m is null) last_state_m = state_m;

		if (this.health > 0) {
			handle_update_alive();
		} else {
			player_anim.ChangeAnimation("wolf_dead");
		}

		// update states.
		last_state_k = state_k;
		last_state_m = state_m;
	}

	private void handle_update_alive() {
		this.LightingState = LightingState.Moonlit;
		if (shaders > 0) {
			this.LightingState = LightState.InShade;
		}
		this.shaders = 0;

		float final_speed = speed;
		if (HiddenState == HideState.Hidden) final_speed -= sneak_slowdown;
		if (CurrentForm == Form.Werewolf) final_speed += werewolf_boost;
		if (CurrentForm == Form.Wolf) final_speed += wolf_boost;

		is_crouching = false;
		if (is_grounded && state_k.IsKeyDown(Keys.Down)) {
			is_crouching = true;
			if (allow_transform) transform_counter++;
		}

		// Only wolf and werewolf can jump!
		if (is_grounded && CurrentForm != Form.Human && last_state_k.IsKeyUp(Keys.Space) && state_k.IsKeyDown(Keys.Space)) {
			y_velocity = jump_velocity;
			is_grounded = false;
		}

		if (is_grounded) {
			if (is_crouching && transform_counter >= transform_max && allow_transform) {
				allow_transform = false;
				transform_player();
				transform_counter = 0;
			}

			if (is_crouching) {
				// Animation
				if (CurrentForm == Form.Human) {
					player_anim.ChangeAnimation("human_crouch", true);
				} else if (CurrentForm == Form.Wolf) {
					if (LightingState == LightState.InShade) player_anim.ChangeAnimation("wolf_light_crouch", true);
					else player_anim.ChangeAnimation("wolf_dark_crouch", true);
				} else {
					player_anim.ChangeAnimation("werewolf_crouch", true);
				}
			}

			if (!is_crouching) {
				handle_normal_movement(final_speed);
			}
		}

		if (!is_grounded) {
			// Just to be sure, reset this stuff while jumping
			allow_transform = true;
			transform_counter = 0;
			is_crouching = false;
			this.Position += Vector2(x_velocity*1.4f, -y_velocity);

			foreach(GameObject v; parent.Entities) {
				if ((cast(Villager)v).Hitbox.Intersects(this.Hitbox)) {
					// If the player has applied damage to the NPC, halve the velocity.
					if ((cast(Villager)v).Damage(CurrentForm, x_velocity, 50)) {
						x_velocity /= 2f;
						break;
					}
				}
			}

			// Animation
			if (CurrentForm == Form.Wolf) {
				if (LightingState == LightState.InShade) player_anim.ChangeAnimation("wolf_light_jump", true);
				else player_anim.ChangeAnimation("wolf_dark_jump", true);
			} else {
				player_anim.ChangeAnimation("werewolf_jump", true);
			}

			if (Position.X+((player_tex.Width/8)/4) < 0) {
				Position = Vector2(-((player_tex.Width/8)/4), Position.Y);
			}

			if (Position.X+(player_tex.Width/8) > parent.LevelSizePX) {
				Position = Vector2(parent.LevelSizePX-(player_tex.Width/8), Position.Y);
			}
		}

		this.Position += Vector2(0, -y_velocity);

		Hitbox = new Rectangle(cast(int)Position.X+80, cast(int)Position.Y, 64, player_tex.Height/8);

		// Handle gravity.
		y_velocity -= Gravity;

		// Make sure player doesn't fall through the ground.
		if (this.Position.Y + Hitbox.Height > 0) {
			y_velocity = 0;
			is_grounded = true;
			this.Position = Vector2(this.Position.X, -Hitbox.Height);
		}

		if (Position.Y+this.Hitbox.Height < 0) is_grounded = false;
		else {
			is_grounded = true;
		}

		handle_camera();

		handle_animation();

		panic_transform_player();
		health -= overtime_damage;

	}

	private void handle_normal_movement(float final_speed) {
		allow_transform = true;
		transform_counter = 0;
		// TODO: improve the input situration here, lol
		if (state_k.IsKeyDown(Keys.Left)) {

			Position -= Vector2(final_speed, 0f);
			x_velocity = -final_speed;

			// Animation
			if (this.CurrentForm == Form.Human) {
				player_anim.ChangeAnimation("human_walk");
			} else if (this.CurrentForm == Form.Wolf) {
				if (LightingState == LightingState.Moonlit) player_anim.ChangeAnimation("wolf_dark_walk");
				else player_anim.ChangeAnimation("wolf_light_walk");
			} else {
				player_anim.ChangeAnimation("werewolf_walk");
			}

			flip = SpriteFlip.FlipVertical;
		} else if (state_k.IsKeyDown(Keys.Right)) {

			Position += Vector2(final_speed, 0f);
			x_velocity = final_speed;
			// Animation
			if (this.CurrentForm == Form.Human) {
				player_anim.ChangeAnimation("human_walk");
			} else if (this.CurrentForm == Form.Wolf) {
				if (LightingState == LightingState.Moonlit) player_anim.ChangeAnimation("wolf_dark_walk");
				else player_anim.ChangeAnimation("wolf_light_walk");
			} else {
				player_anim.ChangeAnimation("werewolf_walk");
			}

			flip = SpriteFlip.None;
		} else {
			x_velocity = 0f;

			// Animation
			bool s = (player_anim.AnimationName.endsWith("idle"));
			if (this.CurrentForm == Form.Human) {
				player_anim.ChangeAnimation("human_idle", s);
			} else if (this.CurrentForm == Form.Wolf) {
				if (LightingState == LightingState.Moonlit) player_anim.ChangeAnimation("wolf_dark_idle", s);
				else player_anim.ChangeAnimation("wolf_light_idle", s);
			} else {
				player_anim.ChangeAnimation("werewolf_idle", s);
			}
		}

		if (Position.X+((player_tex.Width/8)/4) < 0) {
			Position = Vector2(-((player_tex.Width/8)/4), Position.Y);
		}

		if (Position.X+(player_tex.Width/8) > parent.LevelSizePX) {
			Position = Vector2(parent.LevelSizePX-(player_tex.Width/8), Position.Y);
		}
	}

	private void transform_player() {
		if (CurrentForm == Form.Wolf) {
			if (LightingState == LightState.InShade) {
				this.CurrentForm = Form.Human;
			} else {
				this.CurrentForm = Form.Werewolf;
			}
			foreach(GameObject go; parent.Entities) {
				(cast(Villager)go).UpdatePlayerKnowledgeState(true);
			}
			return;
		}
		foreach(GameObject go; parent.Entities) {
			(cast(Villager)go).UpdatePlayerKnowledgeState(true);
		}
		this.CurrentForm = Form.Wolf;
	}

	private void panic_transform_player() {
		if ((this.CurrentForm == Form.Human && LightingState == LightState.Moonlit) || 
			(this.CurrentForm == Form.Werewolf && LightingState == LightState.InShade))
			this.CurrentForm = Form.Wolf;
	}

	private void handle_camera() {
		parent.Camera.Origin = (WereshiftGame.Bounds/2)-Vector2((player_tex.Width/8)/2, 0);
		parent.Camera.Position = Vector3(Position.X, Position.Y+((player_tex.Height/8)/2), 0);

		// Cap camera < 0
		if ((parent.Camera.Position - Vector3(((WereshiftGame.Bounds.X/2)/parent.Camera.Zoom)-((player_tex.Width/8)/2), 0f, 0f)).X <= 0) {
			parent.Camera.Position = Vector3(
				(WereshiftGame.Bounds.X/2)/parent.Camera.Zoom-((player_tex.Width/8)/2)-(8/parent.Camera.Zoom), 
				Position.Y+((player_tex.Height/8)/2), 
				0f);
		}

		// Cap camera > level
		if ((parent.Camera.Position + Vector3(((WereshiftGame.Bounds.X/2)/parent.Camera.Zoom) + (32/parent.Camera.Zoom) + ((player_tex.Width/8)/2), 0f, 0f)).X >= (parent.LevelSizePX)) {
			parent.Camera.Position = Vector3(
				(parent.LevelSizePX - ((player_tex.Width/8)/2) - (32/parent.Camera.Zoom)) -((WereshiftGame.Bounds.X/2)/parent.Camera.Zoom), 
				Position.Y+((player_tex.Height/8)/2), 
				0f);
		}

		if (this.watchers > 0) parent.ZoomOutCamera();
		else parent.ZoomInCamera();
		this.watchers = 0;
		HiddenState = HideState.Hidden;
	}

	private void handle_animation() {
		player_anim.Update();
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Draw(player_tex, new Rectangle(cast(int)Position.X, cast(int)Position.Y, player_tex.Width/8, player_tex.Height/8), new Rectangle(player_anim.GetAnimationX()*(player_tex.Width/8), player_anim.GetAnimationY()*(player_tex.Height/8), player_tex.Width/8, player_tex.Height/8), Color.White, flip);
	}
}