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
module wereshift.screens.startscreen;
import wereshift.screen;
import wereshift.ui;
import wereshift.game;
import std.stdio;

public class StartScreen : Screen {

	private UIButton play_game;
	private UIButton exit_game;

	this(ContentManager content) {
		super(content);
		Init();
	}

	public override void Init() {
		play_game = new UIButton(new Rectangle(0, 0, 256, 32), null, "Start Game", "Starts the game");
		exit_game = new UIButton(new Rectangle(0, 0, 256, 32), null, "Exit", "Exits the game");
	}

	public StartScreen SetPlayGameCallback(UIButton.ButtonCallback callback) {
		play_game.SetCallback(callback);
		return this;
	}

	public StartScreen SetExitGameCallback(UIButton.ButtonCallback callback) {
		exit_game.SetCallback(callback);
		return this;
	}

	public override void Update(GameTimes game_time) {
		play_game.Area.X = (cast(int)WereshiftGame.Bounds.X/2)-(play_game.Area.Width/2);
		play_game.Area.Y = (cast(int)WereshiftGame.Bounds.Y/2)-(play_game.Area.Height/2);
		exit_game.Area.X = (cast(int)WereshiftGame.Bounds.X/2)-(exit_game.Area.Width/2);
		exit_game.Area.Y = (cast(int)WereshiftGame.Bounds.Y)-(exit_game.Area.Height)-32;
		
		exit_game.Update(game_time);
		play_game.Update(game_time);
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Begin();
		play_game.Draw(game_time, sprite_batch);
		exit_game.Draw(game_time, sprite_batch);
		Vector2 wss = UIDesign.UI_FONT.MeasureString("WERESHIFT", 2f);
		Vector2 pos = Vector2((WereshiftGame.Bounds.X/2)-(wss.X/2), 64);
		UIDesign.UI_FONT.DrawString(sprite_batch, "WERESHIFT", pos, 2f, Color.White, game_time, true, 2f);
		sprite_batch.End();
	}
}