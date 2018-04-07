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
module wereshift.random;
import rnd = std.random;

public class Random {
	private rnd.Random random;
	private int seed;

	this() {
		import core.stdc.time;
		this.seed = cast(int)time(null);
		random = rnd.Random(this.seed);
	}

	this (int seed) {
		this.seed = seed;
		random = rnd.Random(seed);
	}

	public int Next() {
		advance_seed();
		return rnd.uniform!int(random);
	}

	public int Next(int max) {
		advance_seed();
		return rnd.uniform(0, max, random);
	}

	public int Next(int min, int max) {
		advance_seed();
		return rnd.uniform(min, max, random);
	}

	private void advance_seed() {
		this.seed++;
		random.seed(this.seed);
	}
}