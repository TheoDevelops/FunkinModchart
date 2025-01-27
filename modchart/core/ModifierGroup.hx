package modchart.core;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import modchart.Modifier;
import modchart.core.util.Constants.ArrowData;
import modchart.core.util.Constants.RenderParams;
import modchart.core.util.Constants.Visuals;
import modchart.core.util.ModchartUtil;
import modchart.modifiers.*;
import modchart.modifiers.false_paradise.*;
import openfl.geom.Vector3D;

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:structInit
@:publicFields
class ModifierOutput {
	var pos:Vector3D;
	var visuals:Visuals;
}

@:allow(modchart.Modifier)
class ModifierGroup {
	public static var GLOBAL_MODIFIERS:Map<String, Class<Modifier>> = [
		'reverse' => Reverse,
		'transform' => Transform,
		'opponentswap' => OpponentSwap,
		'drunk' => Drunk,
		'bumpy' => Bumpy,
		'tipsy' => Tipsy,
		'tornado' => Tornado,
		'invert' => Invert,
		'square' => Square,
		'zigzag' => ZigZag,
		'beat' => Beat,
		'boost' => Boost,
		'receptorscroll' => ReceptorScroll,
		'sawtooth' => SawTooth,
		'mini' => Mini,
		'rotate' => Rotate,
		'fieldrotate' => FieldRotate,
		'centerrotate' => CenterRotate,
		'confusion' => Confusion,
		'stealth' => Stealth,
		'scale' => Scale,
		'skew' => Skew,
		// YOU NEVER STOOD A CHANCE
		'infinite' => Infinite,
		'schmovindrunk' => SchmovinDrunk,
		'schmovintipsy' => SchmovinTipsy,
		'schmovintornado' => SchmovinTornado,
		'wiggle' => Wiggle,
		'arrowshape' => ArrowShape,
		'eyeshape' => EyeShape,
		'spiral' => Spiral,
		'counterclockwise' => CounterClockWise,
		'vibrate' => Vibrate,
		'bounce' => Bounce,
		'radionic' => Radionic,
		'schmovinarrowshape' => SchmovinArrowShape,
		'drugged' => Drugged
	];

	private var MODIFIER_REGISTRY:Map<String, Class<Modifier>> = GLOBAL_MODIFIERS;

	private var percents:StringMap<IntMap<Float>> = new StringMap();
	private var modifiers:StringMap<Modifier> = new StringMap();

	private var sortedMods:Vector<String>;

	private var pf:PlayField;

	public function new(pf:PlayField) {
		this.pf = pf;

		__allocModSorting([]);
	}

	@:dox(hide)
	@:noCompletion private function __allocModSorting(newList:Array<String>) {
		return sortedMods = Vector.fromArrayCopy(newList);
	}

	// just render mods with the perspective stuff included
	public function getPath(pos:Vector3D, data:ArrowData, ?posDiff:Float = 0, ?allowVis:Bool = true, ?allowPos:Bool = true):ModifierOutput {
		var visuals:Visuals = {
			scaleX: 1.,
			scaleY: 1.,
			angleX: 0.,
			angleY: 0.,
			angleZ: 0.,
			alpha: 1.,
			zoom: 1.,
			glow: 0.,
			glowR: 1.,
			glowG: 1.,
			glowB: 1.
		};

		if (!allowVis && !allowPos)
			return {pos: pos, visuals: visuals};

		var songPos = Adapter.instance.getSongPosition();
		var beat = Adapter.instance.getCurrentBeat();

		for (i in 0...sortedMods.length) {
			final mod = modifiers.get(sortedMods[i]);

			final args:RenderParams = {
				sPos: songPos,
				fBeat: beat,
				time: data.time + posDiff,
				hDiff: data.hDiff + posDiff,
				receptor: data.receptor,
				field: data.field,
				arrow: data.arrow,
				__holdParentTime: data.__holdParentTime,
				__holdLength: data.__holdLength,
				__holdOffset: data.__holdOffset
			}

			if (!mod.shouldRun(args))
				continue;

			if (allowPos)
				pos = mod.render(pos, args);
			if (allowVis)
				visuals = mod.visuals(visuals, args);
		}
		pos = ModchartUtil.applyViewMatrix(pos);
		pos.z *= 0.001;
		return {
			pos: ModchartUtil.perspective(pos),
			visuals: visuals
		};
	}

	public function registerModifier(name:String, modifier:Class<Modifier>) {
		var lowerName = name.toLowerCase();
		if (MODIFIER_REGISTRY.get(lowerName) != null) {
			trace('There\'s already a modifier with name "$name" registered !');
			return;
		}
		MODIFIER_REGISTRY.set(lowerName, modifier);
	}

	public function addModifier(name:String) {
		var lowerName = name.toLowerCase();
		var modifierClass:Null<Class<Modifier>> = MODIFIER_REGISTRY.get(lowerName);
		if (modifierClass == null) {
			trace('$name modifier was not found !');

			return;
		}
		var newModifier = Type.createInstance(modifierClass, [pf]);
		modifiers.set(lowerName, newModifier);

		final newArr = sortedMods.toArray();
		newArr.push(lowerName);
		__allocModSorting(newArr);
	}

	public function setPercent(name:String, value:Float, field:Int = -1) {
		var lowerName = name.toLowerCase();
		final possiblePercs = percents.get(lowerName);
		final percs = possiblePercs != null ? possiblePercs : getDefaultPerc();

		if (field == -1)
			for (k => _ in percs)
				percs.set(k, value);
		else
			percs.set(field, value);

		percents.set(lowerName, percs);
	}

	public function getPercent(name:String, field:Int):Float {
		final percs = percents.get(name.toLowerCase());

		if (percs != null) {
			// Map.get can return null
			final possiblePerc:Null<Float> = percs.get(field);
			return possiblePerc != null ? possiblePerc : 0;
		}
		return 0;
	}

	private inline function getDefaultPerc():IntMap<Float> {
		final percMap = new IntMap<Float>();

		for (i in 0...Adapter.instance.getPlayerCount())
			percMap.set(i, 0.);
		return percMap;
	}
}
