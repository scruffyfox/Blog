I was asked to create a MySQL backup service at work so we could easily backup any database on our server onto a single SQL executable query script which we can run to re-input all the data back into the database, should it be courupt or get deleted.

I decided to do it in C because, well i’m just that awesome.

Firstly you need to download the MySQL connector for c here: http://dev.mysql.com/downloads/connector/c/ then install it into the right places I.E copy the lib files to the VC/lib folder in Microsoft Visual Studio, and the include paths to the same place.

My knowledge of C is void until now, so what I have coded is to the best of my non-ability.

Firstly we will include the right header files and such

```c
#include <stdio.h>
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include <WinSock.h>
#include <mysql.h>
#include <mysql_com.h>
#include <memory.h>
#include <time.h>

//	Include the mysql libraries
#pragma comment(lib, "libmysql.lib")
```
The #pragma comment(lib, “libmysql.lib”) part of the script basically allows us to link the library of MySQL straight to the script, without us having to add it to the “Additional Dependancies” in the project settings.

Secondly we need to create our prototypes and global variables

```c
//	Prototypes
void backup();
void mysqlDump();
int switchCommand(int argCount, char *arg[]);
void strtolower(char *str);
void mysqlDumpTableStructure(char *row, FILE *file);
void mysqlDumpTableData(char *tableName, FILE *file);
char *replace_char_in_string(char *string, char to_search, char to_replace_with);

//	Global Vars
const char *dbUsername = "";
const char *dbPassword = "";
const char *dbIp = "";
const char *dbSchema = "";
char *outputPath;
MYSQL *mySql;
```

Prototypes allow the C language to use functions straight away in the start up of the script so we don’t have to worry about ordering of the functions or anything. These global variables are defined so we can use them in any function.

Now we create our entry point

```c
//	Main program entry point
int main(int argCount, char *arg[])
{
	outputPath = (char *)calloc(1024 * 5, 1);	

	if (argCount > 1)
	{
		if (switchCommand(argCount, arg) == 1)
		{
			backup();
		}
	}
	else
	{
		printf("%sn", "Type /help for a list of commandsn");
	}

	return 0;
}
```
This function grabs any arguments that are passed through the execution string and calls the switchCommand function to handle the possible options. It also allocates memory to the output path and sets the contents to ‘’ which is an empty character which allows us to write anything to the char without any weird, non-ascii characters. This will assign 5KB of memory.

Next we write the switchCommand function

```c
int switchCommand(int argCount, char *arg[])
{
	int loopCount;

	for (loopCount = 0; loopCount < argCount; loopCount++)
	{
		if (strcmp(arg[loopCount], "/help") == 0)
		{
			printf("/u <username>	- Set the username for the servern");
			printf("/p <password>	- Set the password for the server n");
			printf("/ip <ip>		- Set the ip for the server n");
			printf("/db <schema name> - Set the schema to backupn");
			printf("[/o <path>]		- Set the path for the backup n");

			return 0;
		}
		else if (strstr(arg[loopCount], "/u") != NULL)
		{
			dbUsername = arg[loopCount + 1];
		}
		else if (strstr(arg[loopCount], "/p") != NULL)
		{
			dbPassword = arg[loopCount + 1];
		}
		else if (strstr(arg[loopCount], "/ip") != NULL)		
		{
			dbIp = arg[loopCount + 1];
		}
		else if (strstr(arg[loopCount], "/db") != NULL)
		{
			dbSchema = arg[loopCount + 1];
		}
		else if (strstr(arg[loopCount], "/o") != NULL)
		{
			outputPath = arg[loopCount + 1];
		}
	}

	return 1;
}
```
This function litterally loops through the argument array and compares it to the possible arguments, then sets the global variables accordingly. It returns 1 by default, but 0 if it was a function that didnt use the backup() function (such as “/help”)

Now we create the backup() function.

```c
void backup()
{
	mySql = mysql_init(NULL);

	if (!mysql_real_connect(mySql, dbIp, dbUsername, dbPassword, dbSchema, 0, NULL, 0))
	{
		printf("%s <%s> Username: %s, Password: %s, IP: %sn", "ERROR: Could not connect to MySql database", mysql_error(mySql), dbUsername, dbPassword, dbIp);

		return;
	}

	if (strlen(dbUsername) > 0 && strlen(dbIp) > 0 && strlen(dbSchema) > 0)
	{
		mysqlDump();
	}
}
```

This function initializes the mySql variable, and connects to the databse. If there was no connection, the error is outputted to console, and the application closes. If not, it checks if the username, ip and schema is set, and if it is, call the mysqlDump() function.

Now we will create the mysqlDump function

```c
void mysqlDump()
{
	MYSQL_RES *res;
	MYSQL_ROW row;
	FILE *output;

	char *tmpChar = (char *)calloc(1024 * 5, 1);
	char *outputFilename = (char *)calloc(1024 * 5, 1);
	char *query = "show tables;";		

	mysql_query(mySql, query);
	res = mysql_store_result(mySql);	

	if (strcmp(outputPath, "") == 0)
	{
		sprintf(outputPath, "backup_%s_%i.sql", dbSchema, time(NULL));
	}
	else
	{
		sprintf(tmpChar, "backup_%s_%i.sql", dbSchema, time(NULL));
		strcat(outputPath, tmpChar);
	}

	while ((row = mysql_fetch_row(res)) != NULL)
	{
		output = fopen(outputPath, "a+");
		mysqlDumpTableStructure(row[0], output);
		mysqlDumpTableData(row[0], output);
		fclose(output);
	}

	mysql_free_result(res);
}
```

This function queries the database to show the tables and initializes the output filename. When the query is executed, the function then loops through the result set and calls mysqlDumpTableStructure and mysqlDumpTableData to get the structure and data from each table.

```c
void mysqlDumpTableStructure(char *tableName, FILE *file)
{
	MYSQL_RES *res;
	MYSQL_ROW row;

	char *sql = (char *)calloc(256, 1);
	char *contents = (char *)calloc(1024 * 1024 * 5, 1);
	char *tmpChar = (char *)calloc(1024 * 1024, 1);	

	sprintf(tmpChar, "n/* Table structure for table %s */n", tableName);
	strcat(contents, tmpChar);
	sprintf(tmpChar, "DROP TABLE IF EXISTS `%s`;nn", tableName, tableName);
	strcat(contents, tmpChar);
	sprintf(sql, "show create table `%s`", tableName);

	mysql_query(mySql, sql);
	res = mysql_store_result(mySql);
	row = mysql_fetch_row(res);

	strcat(contents, row[1]);
	strcat(contents, ";");

	fputs(contents, file);
	mysql_free_result(res);

	free(sql);
	free(tmpChar);
}
```

This function gets the table name and creates a MySQL query based on the table name to ‘drop if exists’ which when executed will remove the table if it already exists, it then executes a query ‘show create table’ which returns the SQL needed to create the table.

```c
void mysqlDumpTableData(char *tableName, FILE *file)
{
	MYSQL_RES *res;
	MYSQL_ROW row;

	int rowCount;
	int fieldCount;
	int fieldLoop;
	int index;
	int fieldTypePtr;
	int fieldType[1024];
	char *contents;
	char *sql = (char *)calloc(256, 1);
	char *tmpChar = (char *)calloc(1024 * 1024, 1);

	index = 0;
	fieldTypePtr = 0;			

	sprintf(sql, "select * from `%s`;", tableName);

	mysql_query(mySql, sql);
	res = mysql_store_result(mySql);
	rowCount = mysql_num_rows(res);
	fieldCount = mysql_field_count(mySql);
	contents = (char *)calloc(1024 * 1024 * 5, 1);

	sprintf(tmpChar, "n/* Dumping contents for table %s */n", tableName);
	strcat(contents, tmpChar);

	for (fieldLoop = 0; fieldLoop < fieldCount; fieldLoop++)
	{
		fieldType[fieldTypePtr++] = mysql_fetch_field(res)->type;
	}

	sprintf(tmpChar, "insert into `%s` valuesn", tableName);
	strcat(contents, tmpChar);

	while ((row = mysql_fetch_row(res)) != NULL)
	{
		strcat(contents, "(");

		for (fieldLoop = 0; fieldLoop < fieldCount; fieldLoop++)
		{
			if (row[fieldLoop] == NULL)
			{
				strcat(contents, "null");
			}
			else
			{
				if (fieldType[fieldLoop] == FIELD_TYPE_INT24)
				{
					strcat(contents, row[fieldLoop]);
				}
				else
				{
					row[fieldLoop] = replace_char_in_string(row[fieldLoop], ''', '&#92;&#48;');
					row[fieldLoop] = replace_char_in_string(row[fieldLoop], '\', '/');
					sprintf(tmpChar, "'%s'", row[fieldLoop]);
					strcat(contents, tmpChar);
				}
			}	

			if (fieldLoop < fieldCount - 1)
			{
				strcat(contents, ",");
			}
		}

		strcat(contents, ")");

		if (index < rowCount - 1)
		{
			strcat(contents, ",");
		}
		else
		{
			strcat(contents, ";");
		}

		strcat(contents, "n");
		index++;

		fputs(contents, file);

		free(contents);
		contents = (char *)calloc(1024 * 1024 * 5, 1);
	}

	mysql_free_result(res);	

	free(sql);
	free(tmpChar);
}
```
This function queries a table for all of its data, and queries the table for all of the fields, then loops through the results set and builds up the insert query statement for each row of data.

```c
char *replace_char_in_string(char *string, char to_search, char to_replace_with)
{
	char *buf;
	int i = 0, j = 0;
	char temp[1024];

	while (string[i] !='&#92;&#48;')
	{
		if (string[i] == to_search )
		{
			temp[j] = to_replace_with;
			i++;
			j++;
		}
		else
		{
			temp[j++] = string[i++];
		}
	}

	temp[j] = '&#92;&#48;';
	buf = (char *)malloc(strlen(temp) + 1);
	strcpy(buf, temp);

	return buf;
}
```

Then using this function, it cleans up any single quotes or backspaces that will affect the query if they are not escaped.

The usage of the program is

```
backup.exe /u username /p password /db testDatabase /o "C:/Backups/" /ip 127.0.0.1
```