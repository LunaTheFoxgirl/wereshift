module wereshift.level;
import wereshift.entity;
import wereshift.entities;

public class LevelGenerator {
	private EntityFactory[] entity_generators;

}

public class Level {
	public Player ThePlayer;
	public Entity[] Entities;

	this() {

	}

	public void Generate() {
		ThePlayer = new Player();
	}

	public void Update(GameTime game_time) {

	}

	public void Draw(GameTime game_time) {
		
	}
}