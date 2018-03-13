%% import the basic java functions
import java.net.URL javax.net.ssl.HttpsURLConnection java.io.*;
import java.security.* javax.crypto.*
%% switch on ssl connection debuging
java.lang.System.setProperty('javax.net.debug', 'ssl');
%% 
% create URL object

% url = 'https://api.twitter.com/1.1/search/tweets.json?q=matlab';
url = 'https://api.twitter.com/1.1/statuses/home_timeline.json';
theURL = URL([], url, sun.net.www.protocol.https.Handler);

% create a connection 
httpConn = theURL.openConnection;
httpConn.setRequestProperty('Content-Type', 'application/x-www-form-urlencoded');
% open the connection
% try
%     inStream = BufferedReader( InputStreamReader( httpConn.getInputStream ) );
% catch ME
%     errStream = BufferedReader( InputStreamReader(httpConn.getErrorStream) );
% end
httpConn.connect

% get server certificate and display its issuer info
cert = httpConn.getServerCertificates;
disp(cert(1).getIssuerX500Principal)
disp(cert(2).getIssuerX500Principal)