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
module wereshift.gameobjects.house;
import wereshift.gameobject;
import wereshift.gameobjects;
import wereshift.animation;
import wereshift.game;
import wereshift.random;
import std.stdio;

public class House : GameObject {
	// Looks
	public static Texture2D HouseTexture;
	public static Vector2 TextureSplit = Vector2(2, 3);

	public static Vector2 TextureSplitted() {
		return Vector2(HouseTexture.Width/TextureSplit.X, HouseTexture.Height/TextureSplit.Y);
	}

	public static ResetHouseSpawn() {
		last_house_pos = 0;
	}

	private static Random rng = null;
	private static float last_house_pos = 0;
	private Villager[2] people = [null, null];
	private int[2] people_timer = [0, 0];
	private int people_timeout = 200;

	private Vector2 tex_offset = Vector2(0, 0);

	public Vector2 SpawnPoint() {
		return spawn_point;
	}

	// Collission
	public Rectangle Hitbox;
	public Rectangle HitboxDoor;

	this(Level parent, Vector2 spawn_point) {
		super(parent, spawn_point);
		if (rng is null) rng = new Random();
		tex_offset.Y = rng.Next(0, 3);
	}

	public override void LoadContent(ContentManager content) {
		// Set house texture.
		if (HouseTexture is null) HouseTexture = content.LoadTexture("terrain/buildings");

		// Set the house offset to a random number between 16 and 64.
		float offset = rng.Next(16, 64);

		// If this is the first house in the town, place it in the middle of the map with some offset to make the town largely be in the middle.
		if (last_house_pos == 0) last_house_pos = (((parent.LevelSizePX/2)-(TextureSplitted.X*((this.spawn_point.Y/2))))+(this.spawn_point.X*TextureSplitted.X));

		// Set the spawn point of the house.
		this.spawn_point = Vector2(last_house_pos+(offset*10), 0);

		// Iterate the house position, so that the offset is only applied relatively to the house before this one.
		last_house_pos = (TextureSplitted.X)+last_house_pos+(offset*10);

		// Set the position of the hitbox (for player shade levels)
		this.Hitbox = new Rectangle(cast(int)(this.spawn_point.X+(TextureSplitted.X/4)), cast(int)this.spawn_point.Y, cast(int)(TextureSplitted.X/4)*2, cast(int)TextureSplitted.X);

		if (tex_offset.Y == 0) {
			this.HitboxDoor = new Rectangle(cast(int)this.spawn_point.X+910, cast(int)this.spawn_point.Y, 70, cast(int)TextureSplitted.X);
		} else if (tex_offset.Y == 1) {
			this.HitboxDoor = new Rectangle(cast(int)this.spawn_point.X+330, cast(int)this.spawn_point.Y, 90, cast(int)TextureSplitted.X);
		} else {
			this.HitboxDoor = new Rectangle(cast(int)this.spawn_point.X+910, cast(int)this.spawn_point.Y, 170, cast(int)TextureSplitted.X);
		}

		// Spawn villagers at house
		foreach(i; 0 .. rng.Next(1, 3)) {
			parent.Entities ~= new Villager(parent, Vector2(rng.Next(this.Hitbox.X, this.Hitbox.X+this.Hitbox.Width), 0));
		}
	}

	public override void Update(GameTimes game_time) {
		if (parent.ThePlayer.Hitbox.Intersects(this.Hitbox)) {
			parent.ThePlayer.Shade();
		}
		
		if (!is_full()) {
			foreach(GameObject villager; parent.Entities) {
				Villager v = cast(Villager)villager;
				if (v.AIType == VillagerType.Citizen) {
					if (v.AIState == VillagerAIState.InDanger) {
						if (v.Hitbox.Intersects(this.HitboxDoor)) {
							if (v.CanEnterHouse) {
								if (!is_inside(v)) {
									insert_free(v);
									tex_offset.X = 1;
									v.EnterHouse();
								}
							}
						}
					}
				}
			}
		}

		if (!is_empty()) {
			foreach(i; 0 .. people.length) {
				if (people[i] is null) continue;
				
				if (this.Hitbox.Center.Distance(parent.ThePlayer.Hitbox.Center) < 2000f) {
					people_timer[i] = 0;
				}
				people_timer[i]++;
				if (people_timer[i] >= people_timeout) {
					people[i].LeaveHouse();
					people[i].AIState = VillagerAIState.Idle;
					remove_this(people[i]);
					people_timer[i] = 0;
				}
			}
		}

		if (is_empty()) {
			tex_offset.X = 0;
		}
	}

	private void insert_free(Villager v) {
		foreach(i; 0 .. people.length) {
			if (people[i] is null) {
				people[i] = v;
				return;
			}
		}
	}

	private void remove_this(Villager v) {
		foreach(i; 0 .. people.length) {
			if (people[i] == v) people[i] = null;
		}
	}

	private bool is_full() {
		foreach(i; 0 .. people.length) {
			if (people[i] is null) return false;
		}
		return true;
	}

	private bool is_empty() {
		foreach(i; 0 .. people.length) {
			if (!(people[i] is null)) return false;
		}
		return true;
	}

	private bool is_inside(Villager v) {
		foreach(Villager ve; people) {
			if (v == ve) return true;
		}
		return false;
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		
		sprite_batch.Draw(HouseTexture, 
			new Rectangle(cast(int)spawn_point.X, -cast(int)TextureSplitted.Y, cast(int)TextureSplitted.X, cast(int)TextureSplitted.Y), 
			new Rectangle(cast(int)(tex_offset.X*TextureSplitted.X), cast(int)(tex_offset.Y*TextureSplitted.Y), cast(int)TextureSplitted.X, cast(int)TextureSplitted.Y), 
			Color.White);
	}
}