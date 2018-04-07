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
import wereshift.gameobject;
import wereshift.animation;
import wereshift.game;
import std.string;

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
	private float speed = 3f;
	private float werewolf_boost = 2f;
	private float wolf_boost = 5f;
	private float sneak_slowdown = 2f;
	public Vector2 Position = Vector2(0f, 0f);

	// Collission
	public Rectangle Hitbox;

	// Forms
	public Form CurrentForm = Form.Wolf;

	// Stealth
	public HideState HiddenState = HideState.Hidden;
	public LightState LightingState = LightState.InShade;
	private int watchers = 0;
	private int shaders = 0;

	public void SeePlayer() {
		watchers++;
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
			"human_walk": [
				new AnimationData(0, 1, 10),
				new AnimationData(1, 1, 10),
				new AnimationData(2, 1, 10),
				new AnimationData(3, 1, 10)
			],
			"wolf_dark_idle": [
				new AnimationData(0, 2, 20),
				new AnimationData(1, 2, 20),
				new AnimationData(2, 2, 20),
				new AnimationData(3, 2, 20)
			],
			"wolf_dark_walk": [
				new AnimationData(0, 3, 11),
				new AnimationData(1, 3, 11),
				new AnimationData(2, 3, 11),
				new AnimationData(3, 3, 11)
			],
			"wolf_light_idle": [
				new AnimationData(0, 4, 15),
				new AnimationData(1, 4, 15),
				new AnimationData(2, 4, 15),
				new AnimationData(3, 4, 15)
			],
			"wolf_light_walk": [
				new AnimationData(0, 5, 10),
				new AnimationData(1, 5, 10),
				new AnimationData(2, 5, 10),
				new AnimationData(3, 5, 10)
			],
			"werewolf_idle": [
				new AnimationData(0, 6, 10),
				new AnimationData(1, 6, 10),
				new AnimationData(2, 6, 10),
				new AnimationData(3, 6, 10),
				new AnimationData(4, 6, 10),
				new AnimationData(5, 6, 10)
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
	public override void Update(GameTimes game_time) {
		KeyboardState state_k = Keyboard.GetState();
		MouseState state_m = Mouse.GetState();

		this.LightingState = LightingState.Moonlit;
		if (shaders > 0) {
			this.LightingState = LightState.InShade;
		}
		this.shaders = 0;

		float final_speed = speed;
		if (HiddenState == HideState.Hidden) final_speed -= sneak_slowdown;
		if (CurrentForm == Form.Werewolf) final_speed += werewolf_boost;
		if (CurrentForm == Form.Wolf) final_speed += wolf_boost;

		// TODO: improve the input situration here, lol
		if (state_k.IsKeyDown(Keys.Left)) {

			Position -= Vector2(final_speed, 0f);

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

		handle_camera();

		handle_animation();

		Hitbox = new Rectangle(cast(int)Position.X+80, cast(int)Position.Y, 64, player_tex.Height/8);

		// update states.
		last_state_k = state_k;
		last_state_m = state_m;
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
		if ((parent.Camera.Position + Vector3(((WereshiftGame.Bounds.X/2)/parent.Camera.Zoom)+((player_tex.Width/8)/2), 0f, 0f)).X >= (parent.LevelSizePX)) {
			parent.Camera.Position = Vector3(
				(parent.LevelSizePX - ((player_tex.Width/8)/2) - (32/parent.Camera.Zoom)) -((WereshiftGame.Bounds.X/2)/parent.Camera.Zoom), 
				Position.Y+((player_tex.Height/8)/2), 
				0f);
		}

		if (!this.watchers > 0) parent.ZoomOutCamera();
		else parent.ZoomInCamera();
	}

	private void handle_animation() {
		player_anim.Update();
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Draw(player_tex, new Rectangle(cast(int)Position.X, cast(int)Position.Y, player_tex.Width/8, player_tex.Height/8), new Rectangle(player_anim.GetAnimationX()*(player_tex.Width/8), player_anim.GetAnimationY()*(player_tex.Height/8), player_tex.Width/8, player_tex.Height/8), Color.White, flip);
	}
}