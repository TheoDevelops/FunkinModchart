package modchart.engine;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import openfl.geom.Matrix;

class Proxy extends FlxSprite {
	public var source(default, set):PlayField;

	private function set_source(nsource:PlayField) {
		if (source != null)
			source._removeProxy(this);

		nsource._appendProxy(this);

		return source = nsource;
	}

	public var sourcePlayer(default, set):Int = -1;

	var __lastSrcPlayer:Int = -1;

	private function set_sourcePlayer(n:Int) {
		__lastSrcPlayer = sourcePlayer;

		source._swapProxy(this);

		return sourcePlayer = n;
	}

	public var skew(default, null):FlxPoint = FlxPoint.get();

	var _skewMatrix:Matrix = new Matrix();

	public function new(source:PlayField) {
		this.source = source;

		super();

		moves = false;

		frameWidth = FlxG.width;
		frameHeight = FlxG.height;

		updateHitbox();
	}

	private function transformCmd(cmd:DrawCommand) {
		var vertex = cmd.vertices;
		var vc = Std.int(vertex.length / 2);

		final matrix = this._matrix;
		matrix.identity();

		if (flipX) {
			matrix.scale(-1, 1);
			matrix.translate(width, 0);
		}

		if (flipY) {
			matrix.scale(1, -1);
			matrix.translate(0, height);
		}

		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();
			if (angle != 0)
				matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		updateSkewMatrix();
		_matrix.concat(_skewMatrix);

		_point.set().subtractPoint(offset);
		_point.add(origin.x, origin.y);
		matrix.translate(_point.x, _point.y);

		// if (isPixelPerfectRender(camera)) {
		// 	matrix.tx = Math.floor(matrix.tx);
		// 	matrix.ty = Math.floor(matrix.ty);
		// }

		for (c in 0...vc) {
			var i = c * 2;
			var x = vertex[i];
			var y = vertex[i + 1];

			vertex[i] = matrix.transformX(x, y);
			vertex[i + 1] = matrix.transformY(x, y);
		}

		return cmd;
	}

	function updateSkewMatrix():Void {
		_skewMatrix.identity();

		if (skew.x != 0 || skew.y != 0) {
			_skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
			_skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
		}
	}
}
