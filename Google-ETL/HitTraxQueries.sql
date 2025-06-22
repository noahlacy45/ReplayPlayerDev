-- Create the new table 
CREATE TABLE PlayerDev.HitTraxComplete AS
SELECT 
    p.*,
    s.UserName
FROM 
    PlayerDev.HitTraxSessions s
JOIN 
    PlayerDev.HitTraxPlays p
ON 
    s.Id = p.SnId AND s.UId = p.SnUid;

-- 