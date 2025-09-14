/*1. Names and number of messages sent by each user */

SELECT Users.Name,
       COUNT(Messages.MessageID) AS MessagesSent
FROM Users
JOIN Messages ON Users.UserID = Messages.UserIDSender
GROUP BY Users.UserID, Users.Name
ORDER BY MessagesSent DESC;

/*2. Total number of messages sent stratified by weekday */

SELECT DATENAME(WEEKDAY, Messages.DateSent) AS Weekday,
       COUNT(Messages.MessageID) AS TotalMessages
FROM Messages
GROUP BY DATENAME(WEEKDAY, Messages.DateSent)
ORDER BY MIN(Messages.DateSent);

/*3. Most recent message from each thread that has no response yet */

SELECT Messages.ThreadID,
       Threads.Subject,
       Messages.MessageID,
       Users.Name AS Sender,
       Messages.MessageContent,
       Messages.DateSent
FROM Messages
JOIN Threads ON Messages.ThreadID = Threads.ThreadID
JOIN Users ON Messages.UserIDSender = Users.UserID
WHERE Messages.DateSent = (
    SELECT MAX(Messages2.DateSent)
    FROM Messages AS Messages2
    WHERE Messages2.ThreadID = Messages.ThreadID
)
ORDER BY Messages.ThreadID;

/*4. Conversation with the most messages: all user data and messages in order */

WITH ThreadCounts AS (
    SELECT ThreadID, COUNT(*) AS MsgCount
    FROM Messages
    GROUP BY ThreadID
    ORDER BY MsgCount DESC
    LIMIT 1
)

SELECT Messages.ThreadID,
       Threads.Subject,
       Messages.MessageID,
       UsersSender.Name AS Sender,
       UsersRecipient.Name AS Recipient,
       Messages.MessageContent,
       Messages.DateSent
FROM Messages
JOIN Threads ON Messages.ThreadID = Threads.ThreadID
JOIN Users AS UsersSender ON Messages.UserIDSender = UsersSender.UserID
JOIN Users AS UsersRecipient ON Messages.UserIDRecipient = UsersRecipient.UserID
WHERE Messages.ThreadID = (SELECT ThreadCounts.ThreadID FROM ThreadCounts)
ORDER BY Messages.DateSent ASC;
