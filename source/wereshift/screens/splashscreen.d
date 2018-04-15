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
module wereshift.screens.splashscreen;
import wereshift.screen;
import wereshift.ui;
import wereshift.game;

import std.stdio;

public class SplashScreen : Screen {
	private alias acallback = void delegate(GameState state);
	private UIImage img;
	private acallback callback;

	public void SetCallback(acallback callback) {
		this.callback = callback;
	}

	this(ContentManager content) {
		super(content);
		Init();
	}

	public override void Init() {
		img = new UIImage(new Rectangle(0, 0, 0, 0), null, this.Content.LoadTexture("ui/polyplex8"));
		img.SetPlacement(true);
		img.ImageColor.Alpha = 0;
	}

	private bool fin = true;
	public override void Update(GameTimes game_time) {
		if (fin) {
			img.ImageColor.Alpha = img.ImageColor.Alpha + 2;
			if (img.ImageColor.Alpha >= 255) {
				fin = !fin;
			}
		} else {
			img.ImageColor.Alpha = img.ImageColor.Alpha - 2;
			if (img.ImageColor.Alpha <= 0) {
				callback(GameState.MainMenu);
			}
		}
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, null);
		img.Area = new Rectangle(cast(int)WereshiftGame.Bounds.X/2, cast(int)WereshiftGame.Bounds.Y/2, img.ImageBounds.X/2, img.ImageBounds.Y/2);
		img.Draw(game_time, sprite_batch);
		sprite_batch.End();
	}

	private float scale_factor(Vector2i screen, Vector2i content_size) {
		float screen_aspect = screen.X/screen.Y;
		float content_aspect = content_size.X/content_size.Y;

		float scale_factor;
		if (screen_aspect > content_aspect) {
			scale_factor = screen.Y / content_size.Y;
		} else {
			scale_factor = screen.X / content_size.X;
		}
		return scale_factor;
	}

}