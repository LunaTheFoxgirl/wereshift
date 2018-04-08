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
module wereshift.level;
import wereshift.gameobject;
import wereshift.gameobjects;
import wereshift.iovr;
import wereshift.text;
import wereshift.game;
import wereshift.random;
import std.conv;
import std.stdio;

public enum LightState {
	InShade,
	Moonlit
}

public class LevelGenerator {
	private GameObjectFactory[] entity_generators;
	private GameObjectFactory[] static_generators;
}

public class Level {
	public Player ThePlayer;
	public GameObject[] Entities = [];
	public GameObject[] Scenery = [];
	public GameObject[] ForegroundScenery = [];
	public Camera2D Camera;

	public Text text_handler;

	public int LevelSize;

	public int LevelSizePX() {
		return the_ground.GroundTexture.Width * LevelSize;
	}

	private ContentManager manager;
	private Ground the_ground;

	// Zoom
	private bool zoom_direction = false;
	private float zoom_value = 0.75f;
	private float zoom_min = 0.75f;
	private float zoom_max = 0.8f;
	private float zoom_iter = 0.0005f;


	this(ContentManager manager) {
		this.manager = manager;
	}

	public void ZoomOutCamera() {
		zoom_direction = false;
	}

	public void ZoomInCamera() {
		zoom_direction = true;
	}

	public bool ZoomDirection() {
		return zoom_direction;
	}

	public void Generate() {
		ThePlayer = new Player(this);
		the_ground = new Ground(this);
		text_handler = new Text(manager, "fonts/test_font");
		Camera = new Camera2D(Vector2(0, 0));
		Camera.Zoom = 0.8f;
		LevelSize = 70;
	}

	public void Init() {
		ThePlayer.LoadContent(manager);
		the_ground.LoadContent(manager);

		Random r = new Random();

		int tree_amount = LevelSizePX/2;
		Vector2 last_treepoint = Vector2(128f, 0f);
		Vector2 last_rockpoint = Vector2(0f, 0f);
		Vector2 last_bushpoint = Vector2(0f, 0f);
		foreach(i; 0 .. tree_amount ) {
			int offset = cast(int)last_treepoint.X + (r.Next(64, 256)*10);
			int offset_rock = cast(int)last_rockpoint.X + (r.Next(128, 256)*10);
			int offset_bush = cast(int)last_rockpoint.X + (r.Next(128, 256)*10);

			// Escape, we're done planting trees dammit!
			if (offset > LevelSizePX) break;
			Scenery ~= new Tree(this, Vector2(offset, 0));
			ForegroundScenery ~= new Rock(this, Vector2(offset_rock, 0));
			ForegroundScenery ~= new Bush(this, Vector2(offset_bush, 0));

			last_rockpoint = Vector2(offset_rock, 0f);
			last_bushpoint = Vector2(offset_rock, 0f);
			last_treepoint = Vector2(offset, 0f);
		}

		int house_amount = r.Next(5, 8);
		foreach(i; 0 .. house_amount) {
			Scenery ~= new House(this, Vector2(i, house_amount));
		}

		foreach(GameObject e; Scenery) {
			if (!(e is null))
				e.LoadContent(manager);
		}

		foreach(GameObject e; Entities) {
			if (!(e is null))
				e.LoadContent(manager);
		}

		foreach(GameObject e; ForegroundScenery) {
			if (!(e is null))
				e.LoadContent(manager);
		}
	}

	private void handle_zoom() {
		if (zoom_direction) zoom_value += zoom_iter;
		else zoom_value -= zoom_iter;

		if (zoom_value < zoom_min) zoom_value = zoom_min;
		if (zoom_value > zoom_max) zoom_value = zoom_max;

		// Apply zoom
		Camera.Zoom = zoom_value;
	}

	public void Update(GameTimes game_time) {
		ThePlayer.Update(game_time);
		foreach(GameObject e; Entities) {
			if (!(e is null))
				e.Update(game_time);
		}

		foreach(GameObject e; Scenery) {
			if (!(e is null))
				e.Update(game_time);
		}

		foreach(GameObject e; ForegroundScenery) {
			if (!(e is null))
				e.Update(game_time);
		}

		handle_zoom();
	}

	public void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, Camera);

		foreach(GameObject e; Scenery) {
			if (!(e is null))
				e.Draw(game_time, sprite_batch);
		}

		foreach(GameObject e; Entities) {
			if (!(e is null))
				e.Draw(game_time, sprite_batch);
		}

		ThePlayer.Draw(game_time, sprite_batch);

		foreach(GameObject e; ForegroundScenery) {
			if (!(e is null))
				e.Draw(game_time, sprite_batch);
		}

		the_ground.Draw(game_time, sprite_batch);
		sprite_batch.End();
		
		Color c = Color.White;
		Vector2 ex_size = text_handler.MeasureString("Exposed", 2f);
		Vector2 hd_size = text_handler.MeasureString("Hidden", 2f);


		sprite_batch.Begin();

		// Display "Exposed" text.
		if (ThePlayer.HiddenState == HideState.Hidden) c = Color.Gray;
		text_handler.DrawString(sprite_batch, "Exposed", Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)ex_size.X - 16, cast(int)WereshiftGame.Bounds.Y - (cast(int)ex_size.Y*2) - 16), 2f, c);
		
		// Display "Hidden" text.
		if (ThePlayer.HiddenState == HideState.Hidden) c = Color.White;
		else c = Color.Gray;
		text_handler.DrawString(sprite_batch, "Hidden", Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)hd_size.X - 16, cast(int)WereshiftGame.Bounds.Y - cast(int)hd_size.Y - 16), 2f, c);
		
		
		sprite_batch.End();
	}
}