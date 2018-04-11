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
import polyplex.core.content.gl.textures;
import polyplex.core.content.textures;
import polyplex.utils.logging;

import wereshift.gameobjects;
import wereshift.gameobject;
import wereshift.backdrop;
import wereshift.random;
import wereshift.iovr;
import wereshift.text;
import wereshift.game;
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

const string[] TOWN_PREFIXES = [
	"Charles",
	"Henricks",
	"Chunks",
	"Le grande",
	"Vivande",
	"Langeskov",
	"Lundby",
	"Ronde",
	"Helms",

	// In-joke explaining pronounciation of the word compromise in danish.
	"Komprumi",

	// Owlboy references cause i love that game <3
	"Otus'"
];

const string[] TOWN_POSTFIXES = [
	"Ville",
	"Keep",
	"Gale",
	"Skov",
	"Forest",
	"Town",
	"Valley",
	"Outback",
	"Valley",
	"Hills"
];

public class Level {
	public Player ThePlayer;
	public GameObject[] Entities = [];
	public GameObject[] Scenery = [];
	public GameObject[] Houses = [];
	public GameObject[] ForegroundScenery = [];
	public Camera2D Camera;
	public Text text_handler;
	public int LevelSize;
	public string TownName = "Unnamed Town";
	public Backdrop Background;

	public static Texture2D BoxTex;

	public int LevelSizePX() {
		return the_ground.GroundTexture.Width * LevelSize;
	}

	private ContentManager manager;
	private Ground the_ground;

	// Zoom
	private bool zoom_direction = false;
	private float zoom_value = 0.76f;
	private float zoom_min = 0.76f;
	private float zoom_max = 0.8f;
	private float zoom_iter = 0.0005f;

	~this() {
		foreach(GameObject go; Entities) {
			destroy(go);
			Logger.Debug("Destroyed NPC...");
		}
		destroy(Background);
		Logger.Debug("Destroyed Background...");

		destroy(ThePlayer);
		Logger.Debug("Destroyed the player...");

		foreach(GameObject go; Houses) {
			destroy(go);
			Logger.Debug("Destroyed a house...");
		}

		foreach(GameObject go; ForegroundScenery) {
			destroy(go);
			Logger.Debug("Destroyed a rock/bush...");
		}

		foreach(GameObject go; Scenery) {
			destroy(go);
			Logger.Debug("Destroyed a tree...");
		}
		destroy(the_ground);
		Logger.Debug("Uprooted the ground...");
		House.ResetHouseSpawn();
	}

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
		text_handler = new Text(manager, "fonts/shramp_sans");
		Camera = new Camera2D(Vector2(0, 0));
		Camera.Zoom = 0.8f;
		LevelSize = 160;
		Random twn_rand = new Random();
		town_color = Color.White;
		town_color.Alpha = 0;
		TownName = TOWN_PREFIXES[twn_rand.Next(0, cast(int)TOWN_PREFIXES.length)] ~ " " ~ TOWN_POSTFIXES[twn_rand.Next(0, cast(int)TOWN_POSTFIXES.length)];
	}

	public bool NightEnded() {
		if (Background.PercentageThroughNight >= 1f) return true;
		foreach(GameObject go; Entities) {
			if (go.Alive) return false;
		}
		return true;
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

			Logger.Debug("Placed a happy little tree...");
			Logger.Debug("Placed a happy little rock...");
			Logger.Debug("Placed a happy little bush...");

			last_rockpoint = Vector2(offset_rock, 0f);
			last_bushpoint = Vector2(offset_rock, 0f);
			last_treepoint = Vector2(offset, 0f);
		}

		int house_amount = r.Next(10, 15);
		foreach(i; 0 .. house_amount) {
			House h = new House(this, Vector2(i, house_amount));
			h.LoadContent(manager);
			Houses ~= h;
			Logger.Debug("Placed a happy little house...");
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
		Logger.Debug("Loaded content...");
		Background = new Backdrop(manager, this);
		BoxTex = new GlTexture2D(new TextureImg(1, 1, [255, 255, 255, 255]));
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

		foreach(GameObject e; Houses) {
			if (!(e is null))
				e.Update(game_time);
		}

		foreach(GameObject e; ForegroundScenery) {
			if (!(e is null))
				e.Update(game_time);
		}

		if (!town_name_in) {
			town_color.Alpha = town_color.Alpha + 2;
			if (town_color.Alpha >= 255) {
				town_name_in = true;
			}
		} else {
			if (town_color.Alpha > 0) {
				town_color.Alpha = town_color.Alpha - 2;
			}
		}
		if (!ThePlayer.Alive) {
			dead_color.Alpha = dead_color.Alpha + 2;
		}

		handle_zoom();
		Background.Update(game_time);
	}

	private bool town_name_in = false;

	private Color town_color;
	private Color dead_color = new Color(255, 0, 0, 0);
	public void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.LinearWrap, null, null);
		Background.Draw(game_time, sprite_batch);
		sprite_batch.End();

		sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, Camera);

		foreach(GameObject e; Scenery) {
			if (!(e is null))
				e.Draw(game_time, sprite_batch);
		}

		foreach(GameObject e; Houses) {
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
		if (!ThePlayer.Alive) {
			Vector2 de_size = text_handler.MeasureString("You Died", 3f);
			sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, null);
			Color bg_dead_color = new Color(0, 0, 0, dead_color.Alpha);
			sprite_batch.Draw(
				BoxTex, 
				new Rectangle(0, 0, cast(int)WereshiftGame.Bounds.X, cast(int)WereshiftGame.Bounds.Y),
				new Rectangle(0, 0, 1, 1),
				bg_dead_color);
			text_handler.DrawString(sprite_batch, "You Died", Vector2((cast(int)WereshiftGame.Bounds.X/2) - (cast(int)de_size.X/2), (cast(int)WereshiftGame.Bounds.Y/2) - cast(int)de_size.Y/2), 3f, dead_color, game_time, true, 3f);
		} else {
			Vector2 ex_size = text_handler.MeasureString("Exposed", 1.5f);
			Vector2 hd_size = text_handler.MeasureString("Hidden", 1.5f);
			Vector2 he_size = text_handler.MeasureString("HEALTH: " ~ ThePlayer.Health.text, 1.5f);
			Vector2 twn_size = text_handler.MeasureString(TownName, 2f);
			string time = this.Background.Time.FormatTime("{0}:{1}");
			Vector2 tm_size = text_handler.MeasureString(time, 1.5f);

			sprite_batch.Begin(SpriteSorting.Deferred, Blending.NonPremultiplied, Sampling.PointClamp, null, null);
			// Display "Exposed" text.
			if (ThePlayer.HiddenState == HideState.Hidden) c = Color.Gray;
			text_handler.DrawString(sprite_batch, "Exposed", Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)ex_size.X, cast(int)WereshiftGame.Bounds.Y - ((cast(int)ex_size.Y*2))), 1.5f, c, game_time, true, 2f);
			
			// Display "Hidden" text.
			if (ThePlayer.HiddenState == HideState.Hidden) c = Color.White;
			else c = Color.Gray;
			text_handler.DrawString(sprite_batch, "Hidden", Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)ex_size.X, cast(int)WereshiftGame.Bounds.Y - cast(int)hd_size.Y), 1.5f, c, game_time, true);
			
			text_handler.DrawString(sprite_batch, "Night " ~ GAME_INFO.Night.text, Vector2(32, 32), 1.5f, Color.White, game_time);
			

			float shake = (1f-(ThePlayer.Health/100f))*4f;

			text_handler.DrawString(sprite_batch, "HEALTH: " ~ ThePlayer.Health.text, Vector2(4, cast(int)WereshiftGame.Bounds.Y - cast(int)he_size.Y), 1.5f, Color.Red, game_time, true, shake);
			
			if (town_color.Alpha > 0) text_handler.DrawString(sprite_batch, TownName, Vector2((cast(int)WereshiftGame.Bounds.X/2) - (cast(int)twn_size.X/2), (cast(int)WereshiftGame.Bounds.Y/2) - cast(int)twn_size.Y/2), 2f, town_color, game_time, true, 2f);
			text_handler.DrawString(sprite_batch, time, Vector2(cast(int)WereshiftGame.Bounds.X - cast(int)tm_size.X, tm_size.Y/2), 1.5f, Color.White, game_time, true, 2f);
		}
		sprite_batch.End();
	}
}