package client.slugger;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.StrictMode;
import android.util.Log;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;

public class MainActivity extends Activity {

  private SensorManager mSensorManager;
  private Sensor mAccelerometer;
  private Socket connection;
  AccReader accReader;
  final static String HOST_NAME = "10.1.1.147";
  final static int    HOST_PORT = 9595;
  private DataOutputStream dataOutputStream;

  @SuppressLint({ "NewApi", "NewApi", "NewApi" })
  @Override
    public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      setContentView(R.layout.activity_main);

      mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
      mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

      StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
      StrictMode.setThreadPolicy(policy);

      try {
        connection = new Socket(HOST_NAME, HOST_PORT);

        if (connection.isConnected()) {
            dataOutputStream = new DataOutputStream(connection.getOutputStream());
            accReader = new AccReader();
            mSensorManager.registerListener(accReader, mAccelerometer, SensorManager.SENSOR_DELAY_FASTEST);
        }

      } catch (UnknownHostException e) {
        e.printStackTrace();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }


    public void onBackPressed() {
      mSensorManager.unregisterListener(accReader);

      try {
        connection.close();
      } catch (IOException e) {
        e.printStackTrace();
      }

      finish();
    }

    class AccReader implements SensorEventListener
    {
      public void onSensorChanged(SensorEvent event) {
        if (event.sensor.getType() != Sensor.TYPE_ACCELEROMETER)
          return;

        ByteBuffer bb = ByteBuffer.allocate(12).order(ByteOrder.LITTLE_ENDIAN);
        bb.putFloat(event.values[0] / SensorManager.GRAVITY_EARTH);
        bb.putFloat(event.values[1] / SensorManager.GRAVITY_EARTH);
        bb.putFloat(event.values[2] / SensorManager.GRAVITY_EARTH);

        try {
          dataOutputStream.write(bb.array());
          Log.d("bb", event.values[0] + " " + event.values[1] + " " + event.values[2]);
        } catch (IOException e) {
          e.printStackTrace();
          onBackPressed();
        }
      }


      public void onAccuracyChanged(Sensor sensor, int accuracy) {

      }
    }

}
