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
module wereshift.gameobjects.projectile;
import wereshift.gameobjects;
import wereshift.gameobject;
import wereshift.animation;
import wereshift.game;

enum ProjectileType {
	Bullet,
	Arrow
}

public class Projectile : GameObject {
	public static Texture2D BulletTex;
	public static Texture2D ArrowTex;
	// TODO: Finish this.

	private float gravity = 0.4f;

	private Vector2 velocity;
	private Vector2 position;
	private Vector2i hits;	
	public Rectangle Hitbox;

	public ProjectileType ProjType;

	this(Level level, Vector2 spawn_point, ProjectileType type, Vector2 velocity) {
		super(level, spawn_point);
		this.ProjType = type;
		this.velocity = velocity;
	}

	public override void LoadContent(ContentManager manager) {
		if (BulletTex is null) BulletTex = manager.LoadTexture("projectiles/bullet");
		if (ArrowTex is null) ArrowTex = manager.LoadTexture("projectiles/arrow");

		this.hits = Vector2i(BulletTex.Width, BulletTex.Height);
		if (ProjType == ProjectileType.Arrow) {
			this.hits = Vector2i(ArrowTex.Width, ArrowTex.Height);
		}
	}

	public override void Update(GameTimes game_time) {
		this.position += velocity;

		if (ProjType == ProjectileType.Bullet) {
			this.velocity *= 0.995f;
		} else {
			this.velocity *= 0.95f;
		}

		// If it's an arrow, apply gravity to it
		if (ProjType == ProjectileType.Arrow) this.velocity += Vector2(0, gravity);

		if (this.position.Y > 0) this.velocity = Vector2.Zero;

		this.Hitbox = new Rectangle(cast(int)position.X, cast(int)position.Y, this.hits.X, this.hits.Y);
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		float rot = 0f;
		if (ProjType == ProjectileType.Arrow) {
			sprite_batch.Draw(ArrowTex, Hitbox, new Rectangle(0, 0, ArrowTex.Width, ArrowTex.Height), rot, Vector2(ArrowTex.Width/2, ArrowTex.Height/2), Color.White);
			return;
		}
		sprite_batch.Draw(BulletTex, Hitbox, new Rectangle(0, 0, BulletTex.Width, BulletTex.Height), rot, Vector2(BulletTex.Width/2, BulletTex.Height/2), Color.Yellow);
	}
}