CREATE TABLE urls (
    "Keyword" TEXT NOT NULL,
    "CreationDate" BLOB NOT NULL,
    "ExpirationDate" BLOB,
    "Address" TEXT NOT NULL,
    "Clicks" INTEGER NOT NULL DEFAULT (0),
    "CreatorIP" TEXT NOT NULL
);
