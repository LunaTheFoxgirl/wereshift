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
module wereshift.entities.player;
import wereshift.entity;
import wereshift.animation;
import wereshift.game;
import wereshift.text;
import std.stdio;

public class PlayerFactory : GameObjectFactory {
	public override GameObject Construct(Level level) {
		return new Player(level);
	}
}

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
	private Texture2D wolf;
	private Texture2D werewolf;
	private Texture2D human;

	private Animation wolf_anim;
	private Animation werewolf_anim;
	private Animation human_anim;

	private Text text_drawer;

	//private Animation current_anim;

	private SpriteFlip flip = SpriteFlip.None;


	public Vector2 Position = Vector2(0f, 0f);
	public Form CurrentForm = Form.Human;

	public bool InShade = false;
	public bool Hidden = false;


	this(Level parent) {
		super(parent);
	}

	public override void LoadContent(ContentManager content) {
		wolf = content.LoadTexture("entities/player_wolf");
		human = content.LoadTexture("entities/player_man");
		werewolf = content.LoadTexture("entities/player_werewolf");

		text_drawer = new Text(content, "fonts/test_font");

		human_anim = new Animation([
			"idle_dark": [
				new AnimationData(0, 0, 10),
				new AnimationData(1, 0, 10),
				new AnimationData(2, 0, 10),
				new AnimationData(3, 0, 10)
			],
			"idle_light": [
				new AnimationData(0, 2, 20),
				new AnimationData(1, 2, 20),
				new AnimationData(2, 2, 20),
				new AnimationData(3, 2, 20)

			],
			"walk_dark": [
				new AnimationData(0, 1, 10),
				new AnimationData(1, 1, 10),
				new AnimationData(2, 1, 10),
				new AnimationData(3, 1, 10)

			],
			"walk_light": [
				new AnimationData(0, 3, 5),
				new AnimationData(1, 3, 5),
				new AnimationData(2, 3, 5),
				new AnimationData(3, 3, 5)

			]
		]);
		human_anim.ChangeAnimation("idle_light");
	}

	private MouseState last_state_m;
	private KeyboardState last_state_k;
	public override void Update(GameTimes game_time) {

		KeyboardState state_k = Keyboard.GetState();
		MouseState state_m = Mouse.GetState();

		// TODO: improve the input situration here, lol
		if (state_k.IsKeyDown(Keys.Left)) {
			Position -= Vector2(0.1f, 0f);
			if (InShade) human_anim.ChangeAnimation("walk_dark");
			else human_anim.ChangeAnimation("walk_light");
			flip = SpriteFlip.FlipVertical;
		} else if (state_k.IsKeyDown(Keys.Right)) {
			Position += Vector2(0.1f, 0f);
			if (InShade) human_anim.ChangeAnimation("walk_dark");
			else human_anim.ChangeAnimation("walk_light");
			flip = SpriteFlip.None;
		} else {
			if (InShade) human_anim.ChangeAnimation("idle_dark");
			else human_anim.ChangeAnimation("idle_light");
		}

		if (state_m.IsButtonPressed(MouseButton.Left) && last_state_m.IsButtonReleased(MouseButton.Left)) {
			InShade = !InShade;
		}

		handle_camera();

		handle_animation();

		// update states.
		last_state_k = state_k;
		last_state_m = state_m;
	}

	private void handle_camera() {
		parent.Camera.Origin = (WereshiftGame.Bounds/2)-Vector2((human.Width/4)/2, (human.Height/4)/2);
		parent.Camera.Position = Vector3(Position.X, Position.Y, 0);
	}

	private void handle_animation() {
		human_anim.Update();
		//werewolf_anim.Update();
		//wolf_anim.Update();
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, parent.Camera);
		if (CurrentForm == Form.Human) {
			sprite_batch.Draw(human, new Rectangle(cast(int)Position.X, cast(int)Position.Y, human.Width/4, human.Height/4), new Rectangle(human_anim.GetAnimationX()*(human.Width/4), human_anim.GetAnimationY()*(human.Height/4), human.Width/4, human.Height/4), Color.White, flip);

		} else if (CurrentForm == Form.Werewolf) {
			sprite_batch.Draw(werewolf, new Rectangle(cast(int)Position.X, cast(int)Position.Y, werewolf.Width/4, werewolf.Height/4), new Rectangle(0, (640/4)*3, 320/4, 640/4), Color.White, flip);

		} else {
			sprite_batch.Draw(wolf, new Rectangle(cast(int)Position.X, cast(int)Position.Y, wolf.Width/4, wolf.Height/4), new Rectangle(0, (640/4)*3, 320/4, 640/4), Color.White, flip);

		}
		sprite_batch.End();
		sprite_batch.Begin();
		Color c = Color.White;
		Vector2 ex_size = text_drawer.MeasureString("Exposed", 2f);
		Vector2 hd_size = text_drawer.MeasureString("Hidden", 2f);
		if (InShade) c = Color.Gray;
		text_drawer.DrawString(sprite_batch, "Exposed", Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)ex_size.X - 16, cast(int)WereshiftGame.Bounds.Y - (cast(int)ex_size.Y*2) - 16), 2f, c);
		if (InShade) c = Color.White;
		if (!InShade) c = Color.Gray;
		text_drawer.DrawString(sprite_batch, "Hidden", Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)hd_size.X - 16, cast(int)WereshiftGame.Bounds.Y - cast(int)hd_size.Y - 16), 2f, c);
		sprite_batch.End();
	}
}