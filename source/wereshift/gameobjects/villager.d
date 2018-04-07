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

public class Villager : GameObject {
	// Looks
	public static Texture2D VillagerMaleTex = null;
	public static Texture2D VillagerFemaleTex = null;

	private static Random rng = null;

	public Animation VillagerAnimation;
	public VillagerGender Gender;

	private Vector2i render_bounds;

	// Movement
	public Vector2 Position;

	private float speed = 3f;
	private float panic_boost = 2f;

	// AI Actions
	public bool Panicking = false;

	this(Level parent, Vector2 spawnpoint) {
		super(parent, spawnpoint);

		if (rng is null) rng = new Random();

		this.Position = spawn_point;
		Gender = VillagerGender.Female;
		if (rng.Next(0, 10) > 3) {
			Gender = VillagerGender.Male;
		}
	}

	public override void LoadContent(ContentManager content) {
		if (VillagerMaleTex is null)
			VillagerMaleTex = content.LoadTexture("entities/m_villager");	
		if (VillagerFemaleTex is null)
			VillagerFemaleTex = content.LoadTexture("entities/f_villager");

		render_bounds = Vector2i(VillagerFemaleTex.Width/4, VillagerFemaleTex.Height/6);
		this.Position -= Vector2(0f, render_bounds.Y);
		VillagerAnimation = new Animation([
			"dark_idle": [
				new AnimationData(0, 0, 10),
				new AnimationData(1, 0, 10),
				new AnimationData(2, 0, 10),
				new AnimationData(3, 0, 10),
			],
			"dark_walk": [
				new AnimationData(0, 1, 10),
				new AnimationData(1, 1, 10),
				new AnimationData(2, 1, 10),
				new AnimationData(3, 1, 10),
			],
			"dark_panic": [
				new AnimationData(0, 2, 10),
				new AnimationData(1, 2, 10),
				new AnimationData(2, 2, 10),
				new AnimationData(3, 2, 10),
			],
			"light_idle": [
				new AnimationData(0, 3, 10),
				new AnimationData(1, 3, 10),
				new AnimationData(2, 3, 10),
				new AnimationData(3, 3, 10),
			],
			"light_walk": [
				new AnimationData(0, 4, 10),
				new AnimationData(1, 4, 10),
				new AnimationData(2, 4, 10),
				new AnimationData(3, 4, 10),
			],
			"light_panic": [
				new AnimationData(0, 5, 10),
				new AnimationData(1, 5, 10),
				new AnimationData(2, 5, 10),
				new AnimationData(3, 5, 10),
			]
		]);
		VillagerAnimation.ChangeAnimation("light_idle");
	}

	public override void Update(GameTimes game_time) {
		VillagerAnimation.Update();
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		if (Gender == VillagerGender.Female) 
			sprite_batch.Draw(VillagerFemaleTex, 
				new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
				new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
				Color.White);

		if (Gender == VillagerGender.Male) 
			sprite_batch.Draw(VillagerMaleTex,
				new Rectangle(cast(int)Position.X, cast(int)Position.Y, render_bounds.X, render_bounds.Y),
				new Rectangle(VillagerAnimation.GetAnimationX() * render_bounds.X, VillagerAnimation.GetAnimationY() * render_bounds.Y, render_bounds.X, render_bounds.Y),
				Color.White);
	}
}