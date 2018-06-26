import winrt;

import std.traits;

static import Windows.UI.Xaml;

mixin WinRTMain;

pragma(msg, winrtFactoryOf!(Windows.UI.Xaml.Application));

class MyApp : Windows.UI.Xaml.Application
{
	override void OnLaunched(void* args)
	{
		Debug.WriteLine("Launched");
	}
}

int rtmain()
{
	//auto inspApp = roActivateInstance("Windows.UI.Xaml.Application");
	auto app = new MyApp;
	auto inspApp = make(app);

	Debug.Inspect(inspApp.handle);

	return 0;
}
