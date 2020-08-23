DROP VIEW IF EXISTS daily_videos;
CREATE VIEW daily_videos AS
SELECT
   vc.channel
  ,v.*
FROM
  (SELECT
    *
  FROM
    (SELECT
       *
      ,date(created_at) AS created_date
      ,(SELECT COUNT(*)+1 FROM videos
      WHERE video_id = x.video_id
      AND date(created_at) = date(x.created_at)
      AND created_at > x.created_at
      ) AS rankno
    FROM
      videos x
    ) x
  WHERE
    rankno = 1
  ) v
  LEFT OUTER JOIN
  (SELECT
    DISTINCT video_id, channel
  FROM
    video_channel_maps x
  ) vc
  USING (video_id)
