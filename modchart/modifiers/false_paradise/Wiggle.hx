package modchart.modifiers.false_paradise;

import flixel.math.FlxAngle;
import modchart.core.util.Constants.ArrowData;
import modchart.core.util.Constants.RenderParams;
import openfl.geom.Vector3D;

class Wiggle extends Modifier {
	override public function render(curPos:Vector3D, params:RenderParams) {
		var wiggle = getPercent('wiggle', params.field);
		curPos.x += sin(params.fBeat) * wiggle * 20;
		curPos.y += sin(params.fBeat + 1) * wiggle * 20;

		setPercent('rotateZ', (sin(params.fBeat) * 0.2 * wiggle) * FlxAngle.TO_DEG);

		return curPos;
	}

	override public function shouldRun(params:RenderParams):Bool
		return getPercent('wiggle', params.field) != 0;
}
