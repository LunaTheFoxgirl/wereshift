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
import wereshift.screens;
import polyplex.core.render.gl.shader;
import polyplex.core;
import polyplex.math;
import polyplex.utils.logging;

import wereshift.gameinfo;
import wereshift.screen;
import wereshift.text;
import wereshift.ui;
import std.conv;
import std.stdio;

public enum GameState {
	SplashScreen,
	MainMenu,
	InGame,
	ScoreScreen
}

public class WereshiftGame : Game {

	private Level current_level;
	private ScoreScreen score_screen;
	private StartScreen start_screen;
	private SplashScreen splash_screen;
	private static WereshiftGame this_game;
	private Text f;
	private GameState game_state = GameState.SplashScreen;

	public static bool GoreOn = false;
	private bool switching_states = false;

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
	}

	public override void LoadContent() {
		if (f is null) f = new Text(sprite_batch, this.Content, "fonts/shramp_sans");
		UIDesign.PrepareUI(this.Content);

		if (this.game_state == GameState.InGame) {
			current_level = new Level(this.Content);
			current_level.Generate();
			current_level.Init();
			current_level.SetCallback({
				this.NextGameState(GameState.ScoreScreen);
			});
			Logger.Debug("Level generated and initialized...");
		} else if (this.game_state == GameState.MainMenu) {
			this.start_screen = new StartScreen(this.Content);
			this.start_screen.SetPlayGameCallback({
				this.NextGameState(GameState.InGame);
			});
			this.start_screen.SetExitGameCallback(&this.Quit);
		} else if (this.game_state == GameState.SplashScreen) {
			this.splash_screen = new SplashScreen(this.Content);
			this.splash_screen.SetCallback(&this.NextGameState);
		} else {
			this.score_screen = new ScoreScreen(this.Content);
			this.score_screen.Init();
			this.score_screen.SetCallback({
				this.NextGameState(GameState.MainMenu);
			});
		}
	}

	public override void Update(GameTimes game_time) {
		UIButton.MouseUpdateBegin();
		switching_states = false;
		if (this.game_state == GameState.InGame) {
			if (!(current_level is null)) {
				current_level.Update(game_time);

				if (switching_states) return;

				if (current_level.NightEnded) {
					NextNight(game_time);
				}
			}
		} else if (this.game_state == GameState.MainMenu) {
			start_screen.Update(game_time);
		} else if (this.game_state == GameState.SplashScreen) {
			splash_screen.Update(game_time);
		} else {
			score_screen.Update(game_time);
		}

		if (Keyboard.GetState().IsKeyDown(Keys.Escape)) {
			this.Quit();
		}
		UIButton.MouseUpdateEnd();
	}

	public void NextGameState(GameState state) {
		this.game_state = state;
		Logger.Info("Changing gamestate to {0}...", this.game_state);
		destroy(current_level);
		destroy(start_screen);
		destroy(splash_screen);
		destroy(score_screen);
		this.LoadContent();
		switching_states = true;
		if (this.game_state == GameState.InGame) {
			GAME_INFO = new GameInfo();
			GAME_INFO.Night = 0;
			GAME_INFO.Souls = 0;
			GAME_INFO.DamageTaken = 0;
		}
	}

	public void NextNight(GameTimes game_time) {
		// TODO: Switch gamestate.
		destroy(current_level);
		current_level = new Level(this.Content);
		current_level.Generate();
		current_level.Init();
		Logger.Debug("Level generated and initialized...");

		// Run one update.
		current_level.Update(game_time);

		GAME_INFO.Night++;
	}

	Color bg = new Color(10, 10, 12);
	private int highest_frametime = 0;
	public override void Draw(GameTimes game_time) {
		if (switching_states) return;
		Drawing.ClearColor(bg);
		// prep frametime values.
		if (Frametime > highest_frametime) highest_frametime = cast(int)Frametime;
		if (Frametime <= highest_frametime-10) highest_frametime = cast(int)Frametime;


		if (this.game_state == GameState.InGame) {
			current_level.Draw(game_time, sprite_batch);
		} else if (this.game_state == GameState.MainMenu) {
			start_screen.Draw(game_time, sprite_batch);
		} else if (this.game_state == GameState.SplashScreen) {
			splash_screen.Draw(game_time, sprite_batch);
		} else {
			score_screen.Draw(game_time, sprite_batch);
		}
		if (switching_states) return;

		// draw frametime values
		sprite_batch.Begin();
		f.DrawString(Frametime.text ~ "ms", Vector2(8, 8), .4f, Color.Red);
		sprite_batch.End();
	}
}