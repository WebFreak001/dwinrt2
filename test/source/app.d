import winrt;

mixin WinRTMain;

int rtmain()
{
	auto inspApp = roActivateInstance("Windows.UI.Xaml.Application");

	Debug.Inspect(inspApp.handle);

	return 0;
}
