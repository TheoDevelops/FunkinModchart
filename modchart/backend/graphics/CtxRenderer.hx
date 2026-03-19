package modchart.backend.graphics;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import haxe.ds.IntMap;
import haxe.ds.Vector;
import modchart.backend.graphics.renderers.*;
import modchart.engine.PlayField;
import openfl.display.BlendMode;

using modchart.backend.util.SortUtil;
using modchart.backend.util.VectorUtil;

class CtxRenderer {
	var ctx:Context;
	var ctxProxies:Array<Proxy>;

	public function new() {}

	var queue:Vector<DrawCommand>;
	var count:Int = 0;

	public function alloc(n:Int) {
		queue = new Vector<DrawCommand>(n);
		count = 0;
	}

	public function emitArrowCmd(item:FlxSprite) {
		final dc = ctx.arrowRenderer.prepare(item);
		if (dc != null)
			dc.zIndex = Std.int(item._z * 1000);
		return dc;
	}

	public function emitHoldCmd(item:FlxSprite) {
		final dc = ctx.holdRenderer.prepare(item);
		if (dc != null)
			dc.zIndex = Std.int(item._z * 1000);
		return dc;
	}

	public function emitPathCmd(item:FlxSprite) {
		final dc = ctx.pathRenderer.prepare(item);
		if (dc != null)
			dc.zIndex = Std.int(item._z * 1000) + 1;
		return dc;
	}

	var emptyVec:openfl.Vector<Int> = new openfl.Vector<Int>(8, true, [for (i in 0...8) 0]);

	public function emit(items:Array<Array<Array<FlxSprite>>>, playfields:Array<PlayField>, proxies:Array<Proxy>) {
		// used for preallocate
		var playfieldCount = playfields.length;

		var receptorCount = 0;
		var arrowCount = 0;
		var holdCount = 0;
		var attachmentCount = 0;

		var pathCount = 0;

		var proxiesAdd = 0;

		for (i in 0...items.length) {
			final curItems = items[i];
			if (curItems.length == 0)
				continue;

			final r = curItems[0].length;
			final a = curItems[1].length;
			final h = curItems[2].length;
			final at = curItems[3].length;

			final sum = r + a + h + at;

			for (proxy in proxies) {
				if (proxy.sourcePlayer == -1 || proxy.sourcePlayer == i)
					proxiesAdd += sum;
			}

			receptorCount += r;
			arrowCount += a;
			holdCount += h;
			attachmentCount += at;
		}

		if (Config.RENDER_ARROW_PATHS)
			pathCount = receptorCount;

		alloc((arrowCount + receptorCount + attachmentCount + holdCount + pathCount) * playfieldCount + proxiesAdd);

		// i is player index
		for (f in 0...playfields.length) {
			var playfield = playfields[f];
			var proxies = playfield._indexedProxies;

			ctx = playfield.context;

			for (player in 0...items.length) {
				var curItems:Array<Array<FlxSprite>> = items[player];

				if (curItems.length == 0)
					continue;

				ctxProxies = proxies[1 + player].concat(proxies[0]);

				// path stuff
				if (pathCount > 0) {
					// iterate through receptors, yes
					for (receptor in curItems[0]) {
						var _ = emitPathCmd(receptor);
						if (_ != null)
							this.append(_);
					}
				}

				final drawHolds = () -> {
					if (holdCount > 0) {
						for (hold in curItems[2]) {
							if (!getVisibility(hold))
								continue;
							var _ = emitHoldCmd(hold);
							if (_ != null)
								this.append(_);
						}
					}
				};

				// holds (behind strums)
				if (Config.HOLDS_BEHIND_STRUM)
					drawHolds();

				// receptors
				if (receptorCount > 0) {
					for (receptor in curItems[0]) {
						if (!getVisibility(receptor))
							continue;

						var _ = emitArrowCmd(receptor);
						if (_ != null)
							this.append(_);
					}
				}

				// holds (infront of strums)
				if (!Config.HOLDS_BEHIND_STRUM)
					drawHolds();

				// tap arrow
				if (arrowCount > 0) {
					for (arrow in curItems[1]) {
						if (!getVisibility(arrow))
							continue;

						var _ = emitArrowCmd(arrow);
						if (_ != null)
							this.append(_);
					}
				}

				// attachments (splashes)
				if (attachmentCount > 0) {
					for (attachment in curItems[3]) {
						if (!getVisibility(attachment))
							continue;

						var _ = emitArrowCmd(attachment);

						if (_ != null)
							this.append(_);
					}
				}
			}
		}

		queue.nullSort((a, b) -> return b.zIndex - a.zIndex);

		var i = 0;
		while (i < count) {
			var item = queue[i];
			for (camera in item.cameras) {
				var dc = camera.startTrianglesBatch(item.graphic, item.antialiasing, item.isColored, item.blend, item.hasColorOffsets, item.shader);
				@:privateAccess final cameraBounds = camera._bounds.set(camera.viewMarginLeft, camera.viewMarginTop, camera.viewWidth, camera.viewHeight);

				final point = FlxPoint.weak(camera.scroll.x * -item.parent.scrollFactor.x, camera.scroll.y * -item.parent.scrollFactor.y);

				if (item.color != null)
					dc.addTriangles(item.vertices.toFloatFlash(), item.indices.toIntFlash(), item.uvs.toFloatFlash(), emptyVec, point, cameraBounds,
						item.color);
				else if (item.colors != null)
					dc.addGradientTriangles(item.vertices.toFloatFlash(), item.indices.toIntFlash(), item.uvs.toFloatFlash(), point, cameraBounds, item.colors);
			}
			i++;
		}
	}

	public function append(dc:DrawCommand) {
		@:privateAccess
		queue[count++] = ctx.parent.transformCmd(dc);

		if (ctxProxies.length > 0)
			appendProxy(dc);
	}

	public function appendProxy(dc:DrawCommand) {
		for (proxy in ctxProxies)
			@:privateAccess
			queue[count++] = proxy.transformCmd(ModchartUtil.cloneDrawCmd(dc));
	}

	private function getVisibility(obj:flixel.FlxObject) {
		@:bypassAccessor obj.visible = false;
		return obj._fmVisible;
	}

	public function dispose() {}
}
