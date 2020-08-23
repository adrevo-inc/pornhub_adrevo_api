DROP VIEW IF EXISTS daily_channels;
CREATE VIEW daily_channels AS
SELECT
  *
FROM
  (SELECT
     *
    ,date(created_at) AS created_date
    ,(SELECT COUNT(*)+1 FROM channels
    WHERE channel = x.channel
    AND label = x.label
    AND date(created_at) = date(x.created_at)
    AND created_at > x.created_at
    ) AS rankno
  FROM
    channels x
  ) x
WHERE
  rankno = 1
