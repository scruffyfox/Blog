I needed a script that polls a file for changes and then executes a command. So I made one.

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>
#include <sys/stat.h>

int mCounter = 0;
int mDelayer = 1000;
time_t mLastTime;
char *mCommand = NULL;
char *mFilePath = NULL;
char *mFileHash = NULL;

int main(int argc, char *argv[], char **envp[]);
void poll();
void delay(int seconds);

int main(int argc, char *argv[], char **envp[])
{
	int i = 0;
	
	if (argc < 2)
	{
		printf("OPTIONS\n");
		printf("-p	Poll time in SECONDS\n");	
		printf("Usage: watch [OPTION] <file> [COMMAND]\n");
	}
	else
	{
		for (i = 0; i < argc; i++)
		{
			if (strcmp(argv[i], "-p") == 0)
			{
				i++;
				mDelayer = atoi(argv[i]);
			}
			else if (i == argc - 2)
			{
				mFilePath = argv[i];
			}
			else if (i == argc - 1)
			{
				mCommand = argv[i];
			}
		}
		
		if (mFilePath == NULL)
		{
			printf("You must provide a FILE\n");
			return 0;
		}
		
		if (mCommand == NULL)
		{
			printf("You must provide a COMMAND\n"); 
			return 0;
		}
		
		poll();		
	}
	
	return 0;
}

void poll()
{
	char buff[255];
	struct stat attributes;	 
	stat(mFilePath, &attributes); 
	time_t t = attributes.st_mtime; 
		
	if (t - mLastTime > 0 && mLastTime > 0)
	{		
		sprintf(buff, "/bin/sh -c \"%s\"", mCommand);
		system(buff);
		
		//	Delay another 3 seconds for large files to flush
		delay(3);
	}
	
	mLastTime = t; 
	mCounter++;  
	
	delay(mDelayer);
	poll();
}

void delay(int seconds)
{
    time_t t = time(NULL);
    while (difftime(time(NULL), t) < seconds);
}
```

At the moment, the script only executes commands from `/bin/sh` which is a linux shell. Im sure you can hack it to work for Windows.