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
module wereshift.game;
import polyplex.core;
import polyplex.math;
import polyplex.utils.logging;

import wereshift.level;
import wereshift.text;
import std.conv;

public class WereshiftGame : Game {

	private Level current_level;
	private static WereshiftGame this_game;
	private Text f;

	public static Vector2 Bounds() {
		return Vector2(this_game.Window.Width, this_game.Window.Height);
	}

	this() {
		super("Wereshift", new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, WindowPosition.Undefined, WindowPosition.Undefined));
		this_game = this;
	}

	public override void Init() {
		this.Content.ContentRoot = "content/";
		Window.AllowResizing = true;
		Window.VSync = true;
	}

	public override void LoadContent() {
		f = new Text(sprite_batch, this.Content, "fonts/test_font");
		current_level = new Level(this.Content);
		current_level.Generate();
		current_level.Init();
	}

	public override void Update(GameTimes game_time) {
		current_level.Update(game_time);
	}

	public override void Draw(GameTimes game_time) {
		Drawing.ClearColor(Color.Black);
		current_level.Draw(game_time, sprite_batch);
		sprite_batch.Begin();
		f.DrawString(Frametime.text ~ " MS frametime\nPlayer Position " ~ current_level.ThePlayer.Position.ToString, Vector2(32, 32), 2f);
		sprite_batch.End();
	}
}