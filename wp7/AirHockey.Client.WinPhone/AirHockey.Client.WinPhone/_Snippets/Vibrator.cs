using System;
using Microsoft.Devices;

namespace AirHockey.Client.WinPhone._Snippets
{
    public class Vibrator
    {
        public static void Vibrate()
        {
            VibrateController.Default.Start(TimeSpan.FromMilliseconds(500));
        }
    }
}
