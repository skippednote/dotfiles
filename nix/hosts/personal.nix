# Personal MacBook.
{ hostname, ... }:

{
  networking.computerName = hostname;
  networking.hostName = hostname;
  networking.localHostName = hostname;
}
