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
module wereshift.animation;

public class AnimationData {
	this(int frame, int animation, int timeout) {
		this.Frame = frame;
		this.Animation = animation;
		this.Timeout = timeout;
	}
	public int Frame;
	public int Animation;
	public int Timeout;
}

public class Animation {
	private string animation_name;
	private int frame;
	private int frame_counter;
	private int frame_timeout;

	AnimationData[][string] Animations;

	this(AnimationData[][string] animations) {
		this.Animations = animations;
	}

	public void ChangeAnimation(string name) {
		if (animation_name == name) return;
		this.animation_name = name;
		this.frame = Animations[animation_name][0].Frame;
	}

	public int GetAnimationX() {
		return Animations[animation_name][frame%Animations[animation_name].length].Frame;
	}

	public int GetAnimationY() {
		return Animations[animation_name][frame%Animations[animation_name].length].Animation;
	}

	public int GetAnimationTimeout() {
		return Animations[animation_name][frame%Animations[animation_name].length].Timeout;
	}

	public void Update() {
		frame_timeout = GetAnimationTimeout();
		if (frame_counter >= frame_timeout) {
			this.frame++;
			frame_counter = 0;
		}
		frame_counter++;
	}
}