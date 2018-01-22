# Giphy

View trending GIFs from [Giphy](https://giphy.com).

Thanks for the opportunity to review this code.  I've inserted my comments inline with the code.  Each comment starts with SH-COMMENT.

My overall comment is that this code could use a bunch of refactoring to make it succinct.  Also, there are serveral places where forced unwrapping of optionals are used, which can lead to an App crash. I would replace most with optional chaining and deal with the nil values gracfully (e.g., default values or error messages).

Thanks,
   Steig Hallquist
