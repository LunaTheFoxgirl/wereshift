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
import wereshift.animation;
import wereshift.game;
import wereshift.random;

public class House : GameObject {
	// Looks
	public static Texture2D HouseTexture;
	private static Random rng = null;
	private static float last_house_pos = 0;

	// Collission
	public Rectangle Hitbox;

	this(Level parent, Vector2 spawn_point) {
		super(parent, spawn_point);
		if (rng is null) rng = new Random();
	}

	public override void LoadContent(ContentManager content) {
		if (HouseTexture is null) HouseTexture = content.LoadTexture("terrain/house_1");
		float offset = rng.Next(16, 32);
		if (last_house_pos == 0) last_house_pos = (((parent.LevelSizePX/2)-(HouseTexture.Width*((this.spawn_point.Y/2))))+(this.spawn_point.X*HouseTexture.Width));
		this.spawn_point = Vector2(last_house_pos+(offset*10), 0);
		last_house_pos = (HouseTexture.Width)+last_house_pos+(offset*10);

		this.Hitbox = new Rectangle(cast(int)this.spawn_point.X+110, cast(int)this.spawn_point.Y, 779, HouseTexture.Height);
	}

	public override void Update(GameTimes game_time) {
		if (parent.ThePlayer.Hitbox.Intersects(this.Hitbox)) {
			parent.ThePlayer.Shade();
		}
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Draw(HouseTexture, 
			new Rectangle(cast(int)spawn_point.X, -HouseTexture.Height, HouseTexture.Width, HouseTexture.Height), 
			new Rectangle(0, 0, HouseTexture.Width, HouseTexture.Height), 
			Color.White);
	}
}