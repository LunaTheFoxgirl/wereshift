module wereshift.app;
import polyplex.core;
import polyplex;
import wereshift.game;

static void main(string[] args) {
	BasicGameLauncher.InitSDL();
	BasicGameLauncher.LaunchGame(new WereshiftGame(), args);
}