# Misc

## PowerShell

* [Jeffrey Snover and the Making of PowerShell](https://corecursive.com/building-powershell-with-jeffrey-snover/)
* [Encrypt Passwords Powershell](https://www.altaro.com/msp-dojo/encrypt-password-powershell/) - Altaro

## Libre Office

0. Inches -> cm - Tools -> Options -> Libre office writer -> General
0. Margings - ALT + SHIFT + P

1. insert images under each other

```code
A better solution is to customise built-in Graphics frame style or to create your own frame style (eventually derived from Graphics so that changes applied to Graphics are also inherited by your custom style). Graphics frame style is the default style applied by Writer when you insert images until you apply another one.

1. Open the style sidepane (F11 except on MacOS or Styles>Manage Styles)
2. Click on the third icon from the left in the toolbar to display frame styles
3. Right-click on Graphics and Modify
4. Go to Wrap tab and uncheck Allow overlap
5. OK
Note that it is sometimes difficult to get the changes immediately effective on existing images.
```

2. put image as character

```code
# https://superuser.com/questions/550240/make-libreoffice-writer-insert-pictures-as-character-by-default

Select Tools > Options > LibreOffice Writer > Formatting Aids > Image > Anchor you can select:

To Pragraph,
To Character or
As Character.
```