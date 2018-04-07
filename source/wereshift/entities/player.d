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
import std.stdio;

public class PlayerFactory : EntityFactory {
	public override Entity Construct(Level level) {
		return new Player(level);
	}
}

public enum Form {
	Werewolf,
	Wolf,
	Human
}

public class Player : Entity {
	private Texture2D wolf;
	private Texture2D werewolf;
	private Texture2D human;

	private Animation wolf_anim;
	private Animation werewolf_anim;
	private Animation human_anim;

	private SpriteFlip flip = SpriteFlip.None;


	public Vector2 Position = Vector2(0f, 0f);
	public Form CurrentForm = Form.Human;


	this(Level parent) {
		super(parent);
	}

	public override void LoadContent(ContentManager content) {
		wolf = content.LoadTexture("entities/player_wolf");
		human = content.LoadTexture("entities/player_man");
		werewolf = content.LoadTexture("entities/player_werewolf");

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

	public override void Update(GameTimes game_time) {

		// TODO: improve the input situration here, lol
		if (Keyboard.GetState().IsKeyDown(Keys.Left)) {
			Position -= Vector2(0.1f, 0f);
			human_anim.ChangeAnimation("walk_light");
			flip = SpriteFlip.FlipVertical;
		} else if (Keyboard.GetState().IsKeyDown(Keys.Right)) {
			Position += Vector2(0.1f, 0f);
			human_anim.ChangeAnimation("walk_light");
			flip = SpriteFlip.None;
		} else {
			human_anim.ChangeAnimation("idle_light");
		}

		handle_camera();

		handle_animation();

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
	}
}