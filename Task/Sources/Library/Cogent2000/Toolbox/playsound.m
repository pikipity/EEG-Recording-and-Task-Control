function playsound( bufnum )
% PLAYSOUND plays sound buffer
%
% Description:
%    Plays a sound buffer.  To create this buffer use commands LOADSOUND or PREPARESOUND.
%
% Usage:
%    PLAYSOUND( buff )
%
% Arguments:
%     buff - buffer number
%
% Examples:
%
% See also:
%      CONFIG_SOUND, PREPARESOUND, PREPAREPURETONE, PREPAREWHITENOISE, LOADSOUND, WAITSOUND,
%      SOUNDPOSITION, SETSOUNDFREQ, GETSOUNDFREQ, GETSOUNDVOL, SETSOUNDVOL
%
% Cogent 2000 function.
%
% $Rev: 218 $ $Date: 2010-10-27 12:06:55 +0100 (Wed, 27 Oct 2010) $

global cogent;

error( checksound(bufnum) );
CogSound( 'play', cogent.sound.buffer(bufnum) );