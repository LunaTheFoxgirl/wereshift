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
module wereshift.app;
import polyplex.utils.logging;
import polyplex.core;
import polyplex;
import polyplex.math;
import wereshift.game;
import wereshift.gameinfo;

static void main(string[] args) {
	LogLevel |= LogType.Debug;
	LogLevel |= LogType.Info;
	LogLevel |= LogType.Error;
	LogLevel |= LogType.Fatal;
	
	GAME_INFO = new GameInfo();
	GAME_INFO.Night = 0;
	GAME_INFO.Souls = 0;
	try {
		BasicGameLauncher.InitSDL();
		BasicGameLauncher.LaunchGame(new WereshiftGame(), args);
	} catch (Exception ex) {
		Logger.Fatal("The game crashed!\nReason:\n{0}", ex.message);
	} catch (Error ex) {
		Logger.Fatal("The game crashed!\nReason:\n{0}", ex.message);
	}
}