module winrt.entrypoint;

import winrt;

extern(D) int rtmain();

mixin template WinRTMain(ApartmentType apartmentType = ApartmentType.multiThreaded)
{
	pragma(lib, "User32");
	pragma(lib, "windowsapp");
	pragma(lib, "uuid");

	enum UsedApartmentType = apartmentType;

	extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		import core.runtime;

		int result;
		try
		{
			Runtime.initialize();
			scope (exit)
				Runtime.terminate();

			init_apartment(apartmentType);
			scope (exit)
				uninit_apartment();

			return rtmain();
		}
		catch (Throwable e)
		{
			import core.sys.windows.windows : MessageBoxA, MB_ICONEXCLAMATION;
			import std.string : toStringz;

			Debug.WriteLine("Exception:\n%s", e);
			MessageBoxA(null, e.toString.toStringz, null, MB_ICONEXCLAMATION);
			return 1;
		}
	}
}