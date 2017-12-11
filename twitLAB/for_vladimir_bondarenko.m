%% My current status using the code from: callTwitterAPI for a GET call (I have removed the code for the POST call)
% Hi Vladimir,
% Below, some command line scripting for an API call to (I removed key, token information etc)
% ".../statuses/home_timeline.json". It works as long as I do not try to
% pass data -- (eg params.count, commented out).
% The error occurs at the point where the BufferedReader is called.
% btw I have been using:
% https://dev.twitter.com/apps/4145370/oauth
% It is excellent.
% Kind regards and thanks for your ongoing support!
% Tobe

%% Set credentials:
clear all
credentials.ConsumerKey = ' - ';
credentials.ConsumerSecret = ' - ';
credentials.AccessToken = ' - ';
credentials.AccessTokenSecret = ' - ';
twtr.credentials = credentials;

%% works, unless I uncomment line 24.
params = '';
%n_tweets = 10; params.count = num2str(n_tweets);
httpMethod = 'GET';
url = 'http://api.twitter.com/1.1/statuses/home_timeline.json';

%% The wrapped java
import java.net.URL java.net.URLConnection java.io.*;
import java.security.* javax.crypto.*

% Define the percent encoding function:
percentEncode = @(str) strrep( char( java.net.URLEncoder.encode(str,'UTF-8') ),'+','%20');

theURL = URL(url)
% Open http connection:
httpConn = theURL.openConnection;
httpConn.setRequestProperty('Content-Type', 'application/x-www-form-urlencoded');

% Set authorization property if required:
% define oauth parameters:
signMethod = 'HMAC-SHA1';
params.oauth_consumer_key = twtr.credentials.ConsumerKey;
params.oauth_nonce = strrep([num2str(now) num2str(rand)], '.', '');
params.oauth_signature_method = signMethod;
params.oauth_timestamp = int2str((java.lang.System.currentTimeMillis)/1000);
params.oauth_token = twtr.credentials.AccessToken;
params.oauth_version = '1.0A';
params = orderfields(params);
%%
% Compose oauth parameters string:
oauth_paramStr = '';
parKey = fieldnames(params);

for ii=1:length(parKey)
    parVal = percentEncode( params.(parKey{ii}) );
    oauth_paramStr = [oauth_paramStr parKey{ii} '=' parVal '&'];
end
oauth_paramStr(end) = []; % remove the last ampersand.
% Create the signature base string and signature key:
signStr = [ upper(httpMethod) '&' percentEncode(url) '&'...
    percentEncode(oauth_paramStr) ];
signKey = [twtr.credentials.ConsumerSecret '&'...
    twtr.credentials.AccessTokenSecret];
%%
% Calculate the signature by the HMAC-SHA1 algorithm:
import javax.crypto.spec.* % key spec methods
import org.apache.commons.codec.binary.* % base64 codec
algorithm = strrep(signMethod,'-','');
key = SecretKeySpec(int8(signKey), algorithm);
mac = Mac.getInstance(algorithm);
mac.init(key);
mac.update( int8(signStr) );
params.oauth_signature = char( Base64.encodeBase64(mac.doFinal)' );
params = orderfields(params);
%%
% Build the HTTP header string:
httpAuthStr = 'OAuth ';
% this section finds all the oauth parameters 
parKey = fieldnames(params);
ix_mask = ~cellfun(@isempty, strfind(parKey,'oauth'));
ix = find(ix_mask');
for ii=ix
    httpAuthStr = [ httpAuthStr ...
        percentEncode(parKey{ii}) '="'...
        percentEncode(params.(parKey{ii})) '", '];
end
httpAuthStr(end-1:end) = []; % remove the last comma-space.

% Set the http connection's Authorization property:
httpConn.setRequestProperty('Authorization', httpAuthStr);
%%
% get the response:
inStream = BufferedReader( InputStreamReader( httpConn.getInputStream ) );
%%
s = '';
sLine = inStream.readLine;
%%
while ~isempty(sLine)
    s = [s sLine];
    sLine = inStream.readLine;
end
inStream.close;
S = char(s);
%%
data = parse_json(char (S) )

%%
