module wereshift.game;
import polyplex.core;
import polyplex.math;
import polyplex.utils.logging;

public class WereshiftGame : Game {

	this() {
		super("Wereshift", new Rectangle(WindowPosition.Undefined, WindowPosition.Undefined, WindowPosition.Undefined, WindowPosition.Undefined));
	}

	public override void Init() {
		this.Content.ContentRoot = "content/";
		
	}

	public override void LoadContent() {

	}

	public override void Update(GameTimes game_time) {
		
	}

	public override void Draw(GameTimes game_time) {

	}
}