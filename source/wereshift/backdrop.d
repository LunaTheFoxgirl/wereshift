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

import polyplex.core;
import polyplex.math;

import std.stdio;

public class Backdrop {
	private Texture2D moon;
	private Texture2D ambient;
	private Texture2D prlx_a;
	private Texture2D prlx_b;
	private Texture2D prlx_c;
	private Level the_level;

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
		prlx_a = manager.LoadTexture("terrain/prlx_forest");
		this.the_level = parent;
	}

	public void Update(GameTimes game_time) {
		if (start_time is null) start_time = new GameTime(game_time.TotalTime.BaseValue);
		current_time = game_time.TotalTime;
		//writeln(PercentageThroughNight, " ", Time.ToString, " ", DawnTime.ToString);
	}

	public void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Draw(ambient,
			new Rectangle(0, 0, cast(int)WereshiftGame.Bounds.X, cast(int)WereshiftGame.Bounds.Y),
			new Rectangle(0, 0, ambient.Width, ambient.Height),
			Color.White);
		sprite_batch.Draw(moon,
			new Rectangle(
				-moon.Width+cast(int)(cast(float)(WereshiftGame.Bounds.X+moon.Width)*PercentageThroughNight), 
				cast(int)((Mathf.Sin(cast(float)(PercentageThroughNight*Mathf.PI))*((WereshiftGame.Bounds.Y/2)-(moon.Height*2))*2)+(moon.Height/2)), 
				moon.Width, 
				moon.Height),
			new Rectangle(0, 0, moon.Width, moon.Height),
			Color.White);
		sprite_batch.Draw(prlx_a,
			new Rectangle(0, (cast(int)WereshiftGame.Bounds.Y/2)-32-cast(int)(the_level.Camera.Position.Y/40f), cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			new Rectangle(cast(int)(the_level.Camera.Position.X/10f), 0,  cast(int)WereshiftGame.Bounds.X, prlx_a.Height),
			Color.White);
	}
}