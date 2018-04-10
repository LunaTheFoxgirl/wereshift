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
module wereshift.backdrop;
import wereshift.gameobjects;
import wereshift.gameobject;
import wereshift.animation;
import wereshift.level;
import wereshift.iovr;
import wereshift.game;
import wereshift.text;
import wereshift.random;

import polyplex.core;
import polyplex.math;

import std.stdio;

public class Backdrop {
	private static Vector2i star_size = Vector2i(4, 4);

	private Texture2D moon;
	private Texture2D ambient;
	private Texture2D mounts;
	private Texture2D prlx_a;
	private Texture2D prlx_b;
	private Texture2D prlx_c;
	private Texture2D stars;
	private Animation star_animation;
	private Level the_level;
	private Vector2[] star_positions;
	private int[] offsets;

	public GameTime Time() {
		return current_time-start_time;
	}

	public GameTime DawnTime() {
		return start_time+GameTime.FromHours(4);
	}

	public float PercentageThroughNight() {
		return this.Time.PercentageOf(this.DawnTime);
	}

	private GameTime current_time = null;
	private GameTime start_time = null;

	this(ContentManager manager, Level parent) {
		moon = manager.LoadTexture("terrain/moon");
		ambient = manager.LoadTexture("terrain/bg_ambient");
		mounts = manager.LoadTexture("terrain/bg_mountains");
		prlx_a = manager.LoadTexture("terrain/prlx_forest");
		stars = manager.LoadTexture("terrain/stars");
		star_animation = new Animation([
			"sparkle": [
				new AnimationData(0, 0, 20),
				new AnimationData(1, 0, 20),
				new AnimationData(2, 0, 20),
				new AnimationData(3, 0, 20),
				new AnimationData(0, 1, 20),
				new AnimationData(1, 1, 20),
				new AnimationData(2, 1, 20),
				new AnimationData(3, 1, 20),
				new AnimationData(0, 2, 20),
				new AnimationData(1, 2, 20),
				new AnimationData(2, 2, 20),
				new AnimationData(3, 2, 20),
				new AnimationData(0, 3, 20),
				new AnimationData(1, 3, 20),
				new AnimationData(2, 3, 20),
				new AnimationData(3, 3, 20),
			]
		]);
		star_animation.ChangeAnimation("sparkle");
		Random rng = new Random();
		foreach(i; 0 .. rng.Next(10, 30)) {
			star_positions.length++;
			star_positions[$-1] = Vector2(cast(float)(rng.Next(0, 101))/100f, cast(float)(rng.Next(0, 101))/100f);

			offsets.length++;
			offsets[$-1] = rng.Next(0, 128);
		}
		this.the_level = parent;
	}

	public void Update(GameTimes game_time) {
		if (start_time is null) start_time = new GameTime(game_time.TotalTime.BaseValue);
		current_time = game_time.TotalTime;
		//writeln(PercentageThroughNight, " ", Time.ToString, " ", DawnTime.ToString);
		star_animation.Update();
	}

	public void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		// Draw stars.
		sprite_batch.Draw(ambient,
			new Rectangle(0, 0, cast(int)WereshiftGame.Bounds.X, cast(int)WereshiftGame.Bounds.Y),
			new Rectangle(0, 0, ambient.Width, ambient.Height),
			Color.White);

		foreach(i; 0 .. star_positions.length) {
			sprite_batch.Draw(stars,
				new Rectangle(
					cast(int)(star_positions[i].X*WereshiftGame.Bounds.X), 
					cast(int)(star_positions[i].Y*(WereshiftGame.Bounds.Y/4)), 
					(stars.Width/star_size.X)/4, 
					(stars.Width/star_size.Y)/4),
				new Rectangle(
					star_animation.GetAnimationX(offsets[i])*(stars.Width/star_size.X), 
					star_animation.GetAnimationY(offsets[i])*(stars.Width/star_size.Y), 
					stars.Width/star_size.X, 
					stars.Height/star_size.Y),
				Color.White);
		}

		sprite_batch.Draw(moon,
			new Rectangle(
				-moon.Width+cast(int)(cast(float)(WereshiftGame.Bounds.X+moon.Width)*PercentageThroughNight), 
				cast(int)((Mathf.Sin(cast(float)(PercentageThroughNight*Mathf.PI))*((WereshiftGame.Bounds.Y/2)-(moon.Height*2))*2)+(moon.Height/2)), 
				moon.Width, 
				moon.Height),
			new Rectangle(0, 0, moon.Width, moon.Height),
			Color.White);

		sprite_batch.Draw(mounts,
			new Rectangle(0, -cast(int)(the_level.Camera.Position.Y/120f)-(cast(int)WereshiftGame.Bounds.Y/4), cast(int)WereshiftGame.Bounds.X, cast(int)WereshiftGame.Bounds.Y),
			new Rectangle(cast(int)(the_level.Camera.Position.X/100f), 0, cast(int)WereshiftGame.Bounds.X, cast(int)WereshiftGame.Bounds.Y),
			Color.White);

		Color drk = new Color(128, 128, 128, 255);
		sprite_batch.Draw(prlx_a,
			new Rectangle(0, (cast(int)WereshiftGame.Bounds.Y/2)-(32+16)-cast(int)(the_level.Camera.Position.Y/40f), cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			new Rectangle(cast(int)(the_level.Camera.Position.X/20f), 0,  cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			drk);

		drk = new Color(128+64, 128+64, 128+64, 255);
		sprite_batch.Draw(prlx_a,
			new Rectangle(0, (cast(int)WereshiftGame.Bounds.Y/2)-cast(int)(the_level.Camera.Position.Y/10f), cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			new Rectangle(cast(int)(the_level.Camera.Position.X/10f), 0,  cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			drk);

		drk = Color.White;
		sprite_batch.Draw(prlx_a,
			new Rectangle(0, (cast(int)WereshiftGame.Bounds.Y/2)+32-cast(int)(the_level.Camera.Position.Y/4f), cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			new Rectangle(cast(int)(the_level.Camera.Position.X/5f), 0,  cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			drk);
	}
}