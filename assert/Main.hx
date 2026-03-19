class Main {
	static function main() {
		var sizes = [100000, 1000000, 100000000];

		for (s in sizes) {
			trace("===== SIZE " + s + " =====");

			// ARRAY
			var t0 = Sys.time();
			var a = new Array<Int>();
			for (i in 0...s)
				a.push(i);
			var t1 = Sys.time();
			var sumA = 0;
			for (i in 0...s)
				sumA += a[i];
			var t2 = Sys.time();

			trace("Array: write=" + (t1 - t0) + "s  read=" + (t2 - t1) + "s");

			// VECTOR
			var t3 = Sys.time();
			var v = new haxe.ds.Vector<Int>(s);
			for (i in 0...s)
				v[i] = i;
			var t4 = Sys.time();
			var sumV = 0;
			for (i in 0...s)
				sumV += v[i];
			var t5 = Sys.time();

			trace("Vector: write=" + (t4 - t3) + "s  read=" + (t5 - t4) + "s");
		}
		Sys.sleep(50);
	}
}
