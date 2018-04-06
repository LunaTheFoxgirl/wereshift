module wereshift.entity;
import wereshift.level;
import polyplex.core;
import polyplex.math;

public abstract class EntityFactory {
	public abstract Entity Construct();
}

public class Entity {
	private Level parent;


	public void Update(GameTimes game_time);
	public void Draw(GameTimes game_time);
}