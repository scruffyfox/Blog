I code quite differently to your average developer, and as (kind of) requested, im going to explain why my method of coding is superior to any one elses.

## Braces

Many developer place their braces on the same line as the control block statement as such:

```java
if (var == true){
	//code
}
```

I personally put braces on new lines

```java
if (var == true)
{
	//code
}
```

The main argument for the former style is that "it takes up less space so you can view more code on the screen". In the 21st century where 2k monitors exist, saving a line of code here or there *really* isnt a valid argument. Especially when source files can most of the time fit all on one screen. Code folding also exists in many good IDEs.

The reasons why I use the latter style is because

1. It separates code easier
2. It clearly shows which trailing brace belong to the control block. Especially when there are many nested blocks
3. When you want to test the code without the control block, you can comment out just the control block and execute as the compiler ignores braces. With braces on same line, you then have to also comment out the matching brace.

What annoys me even more is when people do this:

```java
if (var == true){
	
	//code
}
```

If you're going to leave a space after the control statement anyway, you may as well put the brace there.

## Variable names

In my code, I **never** use single letter variable names (excluding x, y, and z for co-ordinates).

When doing things such as

```java
for (int i = 0; i < 100; i++)
{
	//code
}
```

The variable `i`, even if it's local to only that block, is a very bad practice as it does not clearly describe 

1. What the loop is for
2. What the counter is for

In a for statement, you can have multiple counters

```java
for (int i = 0, j = 10; i < 100; i++, j--)
{
	//code
}
```

This can quickly become messy and unreadable.

```java
for (int arrayIndex = 0, speed = 10; arrayIndex < 100; arrayIndex++, speed--)
{
	//code
}
```

Is much better and more readable.

## Indentation

I **always** use tab indentation. There is absolutely no reason **not** to use tab indentation. If you prefer 2 spaces to a tab, then get a decent IDE and set the tab width to 2 spaces. There is no excuse for this poor practice.

## Casing

This is just my personal preference, but I prefer to camel case my variable names as such: `int testVariable = 0;` and capitalise my class names as such: `TestClass.c`

## Spacing

There should be a space after and before all punctuation (except semicolons and fullstops). You code should be grammatically correct and should practically be a readable sentence.

```java
for (int index = 0; index < 100; index++)
```

Not

```java
for (int index=0; index<100; index++)
```

I also prefer to space after the control name, but not method names. It separates the control block name and makes it look less cluttered.

## Comments

The only time I comment, is when creating Javadoc for my methods. The code should be as simple and concise as possible. If your code needs comments to explain what its doing, you're doing it wrong. Documentation on what the method does is fine though, a developer should be able to know exactly what a method is doing through either the method documentation, or the method name.

## Annotations

I personally prefer to put annotations on the same line as the code its annotation, to me it looks and reads nicer, plus when you have multiple annotations for a single line of code, it ends up pretty messy.

```java
@Getter @Setter @InjectView(R.id.test) private View test;
@Getter @Setter @InjectView(R.id.test2) private View otherTest;
```

instead of 

```java
@Getter
@Setter
@InjectView(R.id.test)
private View test;

@Getter
@Setter
@InjectView(R.id.test2)
private View otherTest;
```

## Consistency

For the love of god, if you're going to code, at least be **consistent** with the way you do. If you work on a project with another developer, follow by their coding style. Seriously, the amount of time both of you will save is phenomenal.

Edit: spelling.