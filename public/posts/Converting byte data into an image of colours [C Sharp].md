I made this as a GUI program before (seen here) but decided to re-make it with threads and better code for a friend who is studying C# in university.

Firstly we create a new Console project in Visual Studio for the language C#. Next, we need to decide what our project arguments are going to be. I decided to write it up in comments so it is easier to reference when creating the code.

```java
// Switch the application arguments
// -f
// -p
// -o <output filename="">
// -v
// -help display this menu
```

With the Main(String[] args) method that is our program entry point, all of the arguments, such as -f, -p, -o etc are parsed within this array. They are all SPACE separated, so any option that has spaces, must be wrapped in quotes.

Right, we’ll create the code to go through the arguments.

```java
public static int imageSize;
public static String fileName;
public static int pixelSize = 1;
public static String outputFileName;
public static Boolean verbrose = true;

public static void Main(string[] args)
{
	int maxSize = args.Length;

	for (int index = 0; index < maxSize; index++)
	{
		switch (args[index])
		{
			case "-f":
			{
				fileName = args[index + 1];
				index++;

				break;
			}

			case "-p":
			{
				pixelSize = int.Parse(args[index + 1]);
				index++;

				break;
			}

			case "-o":
			{
				outputFileName = args[index + 1];
				index++;

				break;
			}

			case "-v":
			{
				verbrose = args[index + 1].Equals("true") ? true: false;
				index++;

				break;
			}

			case "-help":
			{
				Console.WriteLine("-f Sets the input file");
				Console.WriteLine("-p Sets the size of each pixel");
				Console.WriteLine("-o <output filename=""> Sets the output filename");
				Console.WriteLine("-v Sets the verbrose");
				Console.WriteLine("-help display this menu");

				break;
			}
		}
	}

	// Set the default value
	if (outputFileName == null)
	{
		outputFileName = fileName + "_converted.bmp";
	}

	if (maxSize > 0 && fileName != null)
	{
		// Create a new thread for this, because if
		// large files are used, it would crash the app's main
		// UI
		Thread Thread t = new Thread(decodeFile); t.Start();
	}
}
```

This method is pretty self explanatory (excluding the bottom bit), the command is always 1 index before the actual option, so for “program.exe -f test.txt”, the string array would look like “[0] = ‘-f’ [1] = ‘test.txt’ etc etc.
The bottom bit is the mandatory field check and initiates the method ‘decodeFile’ as a separate thread in the application pool. This means it will run without holding up the UI.

Now, lets create the decodeFile method that will open the file and read the bytes from the array.

```java
//  Decode each byte of the file
public static void decodeFile()
{
    //  Open the file ready for reading
    FileStream fStream = File.OpenRead(fileName);
    //  Get the file's info
    FileInfo fInfo = new FileInfo(fileName);
    //  Get the file size
    long fileSize = fInfo.Length;

    //  Calculate how big the bitmap needs to be
    imageSize = (int)Math.Ceiling((Double)fileSize / 3D);
    imageSize = (int)Math.Ceiling((Double)Math.Sqrt(imageSize));
    imageSize *= pixelSize;

    //  Create a dynamic array for our colours
    ArrayList colorList = new ArrayList();

    //  Loop through the file's data and create a color from it, note
    //  We're using a buffer of 1032 because it's devisible by 3 (R, G, B)
    int fileLength = (int)fInfo.Length;
    for (int byteCount = 0; byteCount < fileLength; byteCount += 1032)
    {
        Byte[] buffer = new Byte[1032];
        fStream.Read(buffer, 0, 1032);

        createColor(buffer, ref colorList, fileSize);
    }

    //  Finally create a bitmap. 'ref' just means to pass by referece
    //  So it doesn't create additional memory by copying the arraylist
    //  As a new object
    createBitmap(ref colorList);
}
```

There’s a lot going on in this method, but it’s all commented and should be pretty much self explanatory.

```java
//  Create the colours from the buffer
public static void createColor(Byte[] buffer, ref ArrayList colorList, long fileSize)
{
    int size = buffer.Length;
    for (int index = 0; index < size; index += 3)
    {
        //  If the index is bigger than the array, just give it a black colour
        if (buffer.Length < index + 1)
        {
            buffer[index + 1] = 0x0;
            buffer[index + 2] = 0x0;
        }

        //  Add the color to the array list. Note we're not casting the byte value as an int
        //  Because a byte is essentially an integer ASCII value
        colorList.Add(Color.FromArgb(buffer[index], buffer[index + 1], buffer[index + 2]));

        //  If the index is greater than the file size, break from the array
        if (index > fileSize)
        {
            break;
        }
    }
}
```

Here is the create colour method. What is happening here, basically is you take every 3 byte values from the array, and because their max value is 255, we can interperate them as a colour in each channel (R, G, B) so we just create a colour from RGB. Because byte types can be automatically casted as integers, we don’t need to worry about conversions.

```java
public static void createBitmap(ref ArrayList colorList)
{
    //  Create a new bitmap from our pre calculated image size
    Bitmap b = new Bitmap(imageSize, imageSize);
    Graphics g = Graphics.FromImage(b);

    //  Start off with a black canvas
    g.FillRectangle(new SolidBrush(Color.FromName("black")), 0, 0, imageSize, imageSize);

    //  Get the max colour size and the current index for the arraylist
    int maxSize = colorList.Count;
    int colorIndex = 0;

    //  Loop through the Y coords
    for (int y = 0; y < imageSize; y += pixelSize)
    {
        //  Loop through the X coords
        for (int x = 0; x < imageSize; x += pixelSize)
        {
            //  If the colour index is bigger than the max size of the array, break from the loop
            if (colorIndex >= maxSize)
            {
                break;
            }   

            //  Fill the area in the bitmap with the colour from the arraylist
            g.FillRectangle(new SolidBrush((Color)colorList[colorIndex]), x, y, pixelSize, pixelSize);
            colorIndex++;
        }

        //  If verbrose is on, output the current percentage done
        if (verbrose)
        {
            outputPercentageDone(colorIndex, maxSize);
        }
    }

    //  Create some compression file info
    ImageCodecInfo[] codecInfo = ImageCodecInfo.GetImageEncoders();
    EncoderParameters encoderParams = new EncoderParameters(2);
    encoderParams.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, 255L);
    encoderParams.Param[1] = new EncoderParameter(System.Drawing.Imaging.Encoder.Compression, 255L);

    //  Save the image
    b.Save(outputFileName, codecInfo[4], encoderParams);
}
```

Here is the method that writes the colours to the bitmap and saves it as an image.

```java
//  This function outputs the current percent done of the conversion
public static void outputPercentageDone(int done, int total)
{
    double mDone = (double)done;
    double mTotal = (double)total;

    String output = Math.Round(((mDone / mTotal) * 100), 4) + "% Encode Done";

    Console.SetCursorPosition(0, Console.CursorTop);
    Console.Write(output);

    for (int i = 0; i < " Encode Done".Length; i++)
    {
        Console.Write("\b");
    }
}
```

And here’s the method that outputs the completion to the console when -v true is set in the arguments.