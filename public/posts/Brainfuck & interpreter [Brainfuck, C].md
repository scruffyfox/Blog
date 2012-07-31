Today we’re going to learn how to write code in Brainfuck.

Now you might be asking yourself, what is Brainfuck? Well, Brainfuck is a language which was created by Urban Mullar in 1993. The goal of this creation was to create a language with the smallest compiler, which he did. The compiler came to be 1024 bytes big, but has been made to be 200 bytes big.

The language works by having an allocated array stack of CHARs which can be manipulated and outputted.

The language looks a bit of a… well, brain fuck, but actually its REALLY easy to understand.

Firstly you have the 8 syntax characters, ‘>’, ‘<', '+', '-', '[', ']', ',' and '.' Each one of these characters does a specific command.

Firstly the '<' and '>‘ are used to move through the programs memory. At the start of execution, you start at index 0, using ‘>’ will move you to index 1 and ‘<' back to index 0.

The next characters '+' and '-' are pretty self explanatory, the '+' adds 1 to the current value at the current index, and '-' minuses 1.

After that we have '[' and ']', these are used to iterate. These come in very handy when you want to get to the end of the stack or the start without knowing where the end was. (and by end I mean the last non null value).

Last but not least we have ',' and '.' The comma is used to ask for a user's input for 1 character, and the '.' is used to display the current value at the current index.

Now note: any other character used will be ignored by the interpreter

Now we know what they do lets write our first program!

```c
++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.——.——–.>+.>.
```

Pretty easy right? This simply out puts 'hello world!'. What's going on is

```c
+++++ +++++             initialize counter (cell at index 0) to 10
[                       use loop to set the next four cells to 70/100/30/10
    > +++++ ++              add  7 to cell #1
    > +++++ +++++           add 10 to cell #2
    > +++                   add  3 to cell #3
    > +                     add  1 to cell #4
    <<<< -                  decrement counter (go back to cell #0 and minus 1: Once the counter is 0: the loop will break)
]
> ++ .                  print 'H'
> + .                   print 'e'
+++++ ++ .              print 'l'
.                       print 'l'
+++ .                   print 'o'
> ++ .                  print ' '
<< +++++ +++++ +++++ .  print 'W'
> .                     print 'o'
+++ .                   print 'r'
----- - .               print 'l'
----- --- .             print 'd'
> + .                   print '!'
> .                     print '\n'
```

Remember that a CHAR is an integer representation of ascii characters.

And that's all you need to know about Brainfuck! (Read more at Wikipedia)

It's all well and good writing Brainfuck, but there's no compiler available for 32 or 64 bit machines! So let's write our own in C.

```c
#include <stdio.h>

// This is the program's memory we were talking about
static unsigned char cell[30000];
// This is the pointer, use > and < to navigate through
static unsigned char *ptr;

void processCommand(char command, FILE *file)
{
    char cmd;
    long pos;

    switch (command)
    {
        case '+':
        {
            ++*ptr;
            break;
        }

        case '-':
        {
            --*ptr;
            break;
        }

        case '>':
        {
            ++ptr;
            break;
        }

        case '<':
        {
            --ptr;
            break;
        }

        case '.':
        {
            putchar(*ptr);
            break;
        }

        case ',':
        {
            *ptr = getchar();
            break;
        }

        case '[':
        {
            pos = ftell(file);
            while(*ptr)
            {
                fseek(file, pos, SEEK_SET);
                cmd = getc(file);

                while (cmd != ']' && cmd != EOF)
                {
                    processCommand(cmd, file);
                    cmd = getc(file);
                }
            }
        }
    }
}

int main(int argc, char *argv[], char **envp[])
{
    // Initialize the pointer
    ptr = &cell[0];
    if (argc < 2)
    {
        return 0;
    }
    else
    {
        // Open the file and process the commands
        FILE *bf = fopen(argv[1], "r");

        char cmd;
        while ((cmd = getc(bf)) != EOF)
        {
            processCommand(cmd, bf);
        }          

        fclose(bf);
    }      

    return 0;
}
```

You can compile this on any machine or OS and to use simply drag the Brainfuck file into the exe or in console type "brainfuck file.bf" where file.bf is your Brainfuck file!

[This is a very useful website for debugging and stepping through to see exactly what is going on http://www.lordalcol.com/brainfuckjs/](http://www.lordalcol.com/brainfuckjs/)