# Resource Identifiers
## What is an identifier?
First, what exactly do we mean when we talk about resource identifiers? In short, identifiers give us a way to uniquely address and talk about individual resources in an API. In more technical terms, these identifiers are chunks of bytes (usually a string
value or an integer number) that we can use as the way we point to exactly one
resource in a resource collection. Almost always, these identifiers enable users of an API to perform some type of lookup operation. In other words, these identifiers are
used to address a single resource among some larger collection of resources.

It turns out that we often use identifiers like these in our everyday lives; however,
not all identifiers are equally useful (or even equally unique). For example, many governments use a name and date of birth as an identifier for a person, but there have been plenty of cases where people are mixed up based on the assumption that no two individuals share a name and birth date. A better option, in the United States at least is a Social Security number (a government-assigned nine-digit number), which is used to uniquely identify a person for most financial transactions (e.g., paying taxes or taking out a loan), but this number has its own set of drawbacks. For instance, SSNs are currently limited to a maximum of 1 billion people in total (nine digits), so as the population of the US grows over the years, the country may run out of numbers to give out.

It’s clearly important to have identifiers for resources in an API; however, it’s much
less clear what exactly these identifiers should look like. Put differently, we haven’t
necessarily said what attributes make some identifiers good and others bad. In the
next section, we’ll explore these in more detail.
## What makes a good identifier?
Since almost all resources we’ll need to interact with in our API will need identifiers,
it’s clear that identifiers are important. And since it’s up to us as API designers to
choose the representation of these identifiers, this leaves one big question: what
makes an identifier good? To answer this, we’ll need to explore many different attributes of identifiers and the various options we’ll need to decide between. For now, we’ll focus exclusively on the attributes themselves and make more specific recommendations a bit later.
### Easy to use
The simplest place to start is one of the most obvious: identifiers should be easy to use in the most common scenarios. Perhaps the most typical scenario for an identifier is looking up an individual resource in a web API. This means that sending a request to a server asking “Please give me resource $ID” should be as simple and straightforward as possible while minimizing the opportunity for mistakes. In particular, this must take into consideration the fact that identifiers will often show up in URIs. This means that, for example, using a forward slash ("/") or other reserved characters in an identifier is going to be a bit tricky as they have special meaning in URIs and should probably be avoided.
### Unique
Another obvious requirement of a good identifier is probably that it must be truly
unique. In other words, an identifier must be, by definition, completely one of a kind
or it isn’t really capable of doing its job, which is to uniquely identify a single resource in an API. This might seem a bit overly simplistic, but there are some subtleties we need to address about what it means to be truly unique. One of these is that uniqueness is rarely absolute and instead usually depends on the context or scope in which the identifier is considered. For example, in the scope of computer companies, Apple is considered a unique identifier (there’s only one Apple in the scope of computer companies), but in the scope of all companies Apple isn’t actually unique (there’s also Apple Records, Apple Bank, etc.). We’ll need to decide whether identifiers need to be unique across all resources of the same type, all resources in the same API, or all resources in the world. Admittedly, true global uniqueness is theoretically impossible but should be doable in practice given sufficiently large key spaces (the possible choices for identifiers) and no intentional bad actors.

## Permanent
Next, and slightly more subtle, is the idea that identifiers should probably not change once they’re assigned. This is primarily because of the potential problems introduced (and therefore further decisions to be made) in scenarios where identifiers do end up changing. For example, imagine the case where `Book(id=1234, name="Becoming")` changes its identifier and becomes `Book(id=5678, name="Becoming")`. This on its own might not be a big deal, but consider then that a new book is created: `Book(id=1234, name="Design Patterns")`. In this case, this new book reuses the original identifier (1234), which ultimately means that depending on when you ask for `Book 1234`, you would get different results.

For most scenarios this might not be a big deal, but imagine that users can specify their favorite book and someone selects `Book 1234` to be their favorite (User
(favoriteBook=1234, ...)). This leaves a very reasonable question: is their favorite
book Becoming or Design Patterns? In this world where identifiers aren’t permanent, to answer the question of which book we’re referring to we also need to know when the favorite was selected, or more specifically when it retrieved Book 1234. Without that information, it’s unclear what book we’re actually talking about. As a result, it’s best not only that identifiers are permanent, but that they’re single-use, forever. In other words, once `Book 1234` exists, you should never end up using that same identifier ever again, even after the original `Book 1234` is deleted.

### Fast and easy to generate
So far, we’ve been using simple numbers like “1234” as example identifiers, but it’s
unlikely these will be actual identifiers in real life. Instead, it’s far more likely that
these identifiers will have some element of randomness to them rather than relying
on incrementing integers. Since that typically means there’s more computation in
choosing these identifiers, it’s important to ensure that it doesn’t take too long to
make that choice.

For example, since we said that all identifiers must be permanent and single-use
forever, that means we’ll need to be certain that any ID we choose hasn’t been used already. We could do this by keeping a list of all the resources and choosing IDs at random until we find one that hasn’t been used before, but that’s not exactly the most efficient nor the simplest option out there. It’s also likely to get slower and slower over time, making it an even worse choice. Whatever option we choose, it should be fast and easy, and, most importantly, have predictable performance characteristics.

### Unpredictable
While it’s important that identifiers are fast and easy (and predictably so) when being chosen, it’s also important that it’s difficult for someone to predict what the next identifier will be. Ultimately this comes down to security and can be easily solved with a sufficiently large key space, but if the method of choosing those identifiers is as simple as choosing the next available number, it makes it easier to target and exploit potential vulnerabilities like misconfigured security rules.
For example, if an attacker were just probing around randomly checking for
resources that were accidentally unprotected in a randomly allocated key space of
256-bit integers, there’s a very small chance of landing on a resource that even exists, let alone one that’s misconfigured. If, on the other hand, we use a far more predictable method, such as counting integers over the same key space (1, 2, 3, . . .), then an attacker is almost guaranteed to find resources that exist and can hope to land on one that’s misconfigured to be open to the world rather than locked down.

### Readable, shareable, and verifiable
Next, while we as engineers may hate to admit it, the identifiers we use in our APIs
may at some point need to be communicated over a phone, pasted into a text message, or shared over some other noncomputational medium. This means, for example, that we don’t want confusion between the digit 1, the lowercase L, uppercase I, or the pipe character (|), as writing these down on paper can be tricky (try communicating "l1Il|lI1I1lIl1I1l1lI" over the phone, which is tricky even in code font!). In short, we should consider that identifiers will be interpreted and communicated by humans, so it’s important that they aren’t needlessly difficult in this aspect.

In addition to easy communication, a good identifier makes it easy to quickly
determine if the identifier itself has been copied wrong. In other words, we should be able to tell the difference between a valid identifier that points to nothing and a completely invalid identifier that will never point to anything. One easy way to provide this is to use a simple checksum segment of the identifier. This isn’t such a crazy idea and is used quite often. For example, the identifiers used for books are called ISBNs (https://en.wikipedia.org/wiki/International_Standard_Book_Number) and they work in just this way, where the last digit of a book’s ISBN is used as a check digit to verify that the other digits actually make sense and haven’t been mistyped.

### Informationally dense
Finally, identifiers are going to be used all the time, so size and space efficiency are
going to be important. This means we should aspire to pack as much information into as short a value as possible. This might mean choosing a more dense character set such as Base64 (https://tools.ietf.org/html/rfc4648) over a less dense one, such as simple numerals. In this example, consider that we can only store a total of 10 choices per character if we use numeric IDs, but we can store 64 per character if we use Base64-encoded text.

Optimizing for information density will be a balancing act with the other attributes
that make good identifiers. For example, Base64 has many characters available, but
those characters include both lowercase “i,” uppercase “I,” and the digit “1,” which we learned can be confusing when written down or read. To see how all of this comes together, let’s look at the various design considerations for how we might go about choosing a format for these identifiers.

## What does a good identifier look like?
Now that we have a decent idea of what attributes to look for in a good identifier, we can try implementing a scheme to use for defining resource identifiers. First, we’ll walk through the suggested implementation, and after that we’ll compare it to the various criteria described above.
### Data type
Before we can get into much else, we’ll need to first settle on the data type to use for storing these identifiers. While there are lots of reasonable options, strings, by far, are the most versatile and therefore the recommended option. They provide the highest information density (7 bits of entropy per character used over HTTP), are familiar to use, and provide lots of wiggle room in deciding how to make them easy to share, read, and copy.

While there are several other options, ranging from the common (e.g., positive
integers) to the not so common (raw uninterpreted bytes), these provide artificial limitations imposed by their type (e.g., integers are limited to 10 choices per ASCII character, or ~3.3 bits of entropy per ASCII character over HTTP) or other drawbacks
(e.g., raw bytes are inconvenient to work with in many programming languages).

Since we’ve settled on strings, we have a whole new set of questions to answer. First, what is the character set of these strings? Can we use any valid Unicode string? Or are there limitations? After that, we have to decide whether all characters are allowed. For example, in HTTP, the forward slash character ("/") is generally used to denote a separator, so we probably wouldn’t want that in our identifier. Further, as we learned earlier, some characters (like the pipe character, "|") are easily confused with others (like "I", "1", or "l"). What do we do about these? Let’s start by looking at the character set.

### Character set
As much as I’d love to reminisce and explain Unicode and all its inner workings, not
only would it take far too long, but I suspect there are still gaps in my knowledge of
the standard. As a result, I’ll focus on some simple examples involving character sets
to clarify why this implementation will rely on ASCII (American Standard Code for
Information Interchange).

ASCII is pretty simple: 7 bits of data to represent 128 different characters. This
data is typically shoved into an 8-bit byte, which is used by HTTP requests when interacting with the majority of web APIs today. As you might guess, there are far more than 128 different characters, which is what the Unicode specification aims to solve.

This is great; however, in the mission for ultimate backward compatibility, Unicode
actually allows for more than one way to represent what we would consider the same chunk of text. For example, “á” could be represented as a single Unicode code point (U+00E1) or a composition of the “a” and the accent character code points (U+0061 and U+0301). While these both look like “á” on our screens (or on paper), when stored in a database they look very different—which is exactly the problem since computers don’t see the visual “á” character; they see the bytes that make it up.

While there are certainly ways to get around this (e.g., use Normalization Form C
and other Unicode wizardry), the ambiguities cause far more problems than they’re
worth (e.g., you must now specify how to handle data submitted that isn’t in Normalization Form C, etc.). As a result, the safest bet for modern web APIs is to rely on ASCII for unique identifiers.

Now that we’ve settled on ASCII, we’ll need to decide whether we further limit that
to a subset of the 128 characters due to other concerns.

### Identifier format
While it would be lovely if we could use all 128 characters provided by ASCII (or even
all strings that the Unicode standard can represent), there’s one important and desirable attribute of identifiers we need to consider, which we discussed earlier:
ease of reading, sharing, and copying. This means, quite simply, that we need to avoid characters in ASCII that are easily confused with others or might obfuscate the URL in the HTTP request. This leads us to a very useful serialization format: Crockford’s Base32 (https://www.crockford.com/base32.html).

Crockford’s Base32 encoding relies on using 32 of the available ASCII characters
rather than all 128. This includes A through Z and 0 through 9 but leaves out lots of
the special characters (like the forward slash) as well as I, L, O, and U. While the first
three are left out due to potential confusion (I and l could be confused with 1, and O
could be confused with 0), the third is left out for another interesting reason: profanity. It turns out that by leaving out the U character, it’s actually less likely that you’ll end up with an English-language profanity in your identifiers.

With that said, you might have noticed something else puzzling: why did we bother
to leave out L? After all, the uppercase form can’t be confused with anything; however, it could be confused in the lowercase form (with 1). The reason is that this format has a single canonical form, made up of the uppercase letters (less those mentioned) and 0–9, but it is more accommodating of mistakes when decoding a variety of inputs. In this case, rather than simply saying that L is an invalid character, this algorithm will assume that it was mistaken (in its lowercase form) for the digit 1 and treat it that way. This case insensitivity applies more generally (e.g., a is treated as A) and applies to other potentially confused characters such as O and o (which will be treated as 0). In other words, this format is exceedingly friendly toward mistakes and is designed so that it can do the right thing based on the assumption that those mistakes will continue to occur.

Finally, Crockford’s Base32 encoding treats hyphens as optional, meaning we have
the flexibility of introducing hyphens for readability purposes if we want. This means
that we could have the ID `abcde-12345-ghjkm-67890`, which would be canonically
represented as ABCDE12345GHJKM67890 in Crockford’s Base32.

In short, Crockford’s Base32 encoding satisfies quite a large number of the criteria
outlined in section 6.2: it’s easy to use, easy to make unique, provides reasonably high information density (32 choices or 5 bits per ASCII character), easy to make unpredictable, and, most importantly, very readable, copyable, and shareable thanks to its accommodating and flexible decoding process. Now we just have a few more issues to address.

### Checksums
One of the key requirements listed in section 6.2.6 is the ability to distinguish between
an identifier that is missing (e.g., it was never created or was deleted) and one that
could never possibly exist, which would mean that there was clearly a mistake in the
identifier. One easy way to do this is by including some form of integrity check as part of the identifier. This integrity check typically takes the form of some fixed number of checksum characters at the end of the identifier that is derived from the rest of the content of the identifier itself. Then, when parsing the identifier, we can simply recalculate the checksum characters and test whether they match. If they don’t, then some part of the identifier has been corrupted and it’s considered invalid.

Crockford’s Base32 has a simple algorithm included based on a modulo calculation. In short, we treat the value as an integer, divide it by 37 (the smallest prime number greater than 32), and calculate the remainder of the value. Then we use a single Base37 digit (and the specification includes 5 additional characters for checksum digits) to denote the remainder value.

### Resource type
While we’ve focused primarily on the unique part of the identifier, it’s also very valuable to be able to know the type of the resource from its identifier. In other words, being told a resource has an ID of `abcde-12345-ghjkm-67890` is not very useful unless you’re also told the type of resource involved (so that you can decide what RPC to call or URL to visit to retrieve the resource, for example). One common solution to this is to prefix the ID with the name of the collection involved, such as `books/abcde-12345-ghjkm-67890`. By doing this, we can take that identifier, know what type of resource it’s talking about, and do useful things with it. By using a forward slash as the separator, we end up with a full identifier that would fit in an HTTP request (e.g., `GET /books/abcde-12345-ghjkm-67890`). There are plenty of other options available (e.g., using a colon character, resulting in an ID like `book:abcde-12345-ghjkm-67890`); however, given the friendly relationship with HTTP and usefulness in standard URLs, a forward slash with the collection name tends to be a great fit.
### Hierarchy and uniqueness scope
Now that we’ve decided that we’ll use the collection name as part of the identifier
(e.g., `books/1234` rather than just `1234`), this leads to a new question: how does hierarchy work in an identifier? For example, if we have both `Book` resources and `Page` resources (with pages belonging to books), do we express that hierarchical relationship in the identifier or do we leave each as their own top-level resource? In other words, would `Page` resources have an identifier like `pages/5678` (top-level resources) or `books/1234/pages/5678` (representing hierarchical relationships in the identifier)?

The answer is that hierarchical relationships are very useful and should be used
when appropriate, but there is a specific set of scenarios in which they make sense
(and many where hierarchy is not a good choice). Too often, API designers rely on
hierarchical relationships as an expression of association between two resources
rather than ownership, which can become problematic. For example, we might say,
“Book 1 is currently on Shelf 1” and end up with resource identifiers that look like
`shelves/1/books/1`. Unfortunately, since books tend to move between shelves over time, we’ll want to change the identifier to reflect this move. And, as you might guess, this flies right in the face of the permanence requirements we defined earlier.

While it might be perfectly reasonable to make it a rule that “books shall never
move between shelves” (in which case this identifier would be perfectly reasonable),
this kind of behavioral restriction isn’t really necessary. Instead, we should simply recognize that a book’s current position on a shelf is a mutable attribute of the book itself and store the `shelfId` as a property of the `Book` resource.

When exactly does it make sense to use hierarchical identifiers? In general, APIs
should only rely on hierarchical relationships when they represent true ownership of
one resource over another, specifically focused on the cascading characteristics of the relationship. This means that we should layer resources underneath other resources when we want things like cascading deletion (if you delete the parent, it deletes the children) or cascading security rules (set security rules on the parent and they flow downward to the children). And obviously, as we noted previously, resources should not be capable of moving from one parent to another. For example, while Books might move between Shelves, Pages typically won’t move between Books. This means that we’d identify a Page resource as `books/1/pages/2` rather than just `pages/2`.

Additionally, in cases where we rely on hierarchical identifiers to express an ownership relationship, it’s important to remember that the child resource (the page) only ever exists within the context of its parent (the book). That means that we can never talk about page 2 alone because it leads to the obvious question: page 2 of what book? In practical terms, this means that the identifier of a page always includes the identifier of the parent resource.

This leads to a slightly more subtle question, but one that’s still pretty important:
can we have multiple pages all with the ID “2”? For example, can we have both
`books/1/pages/2` and `books/9/pages/2`? This particular example should hopefully
make the answer to this an obvious yes. After all, lots of books have a second page.
Since the parent resources are different and the identifier is the combination of the
two in a hierarchical relationship, while these two identifiers are similar (as they both end in “pages/2”), the two strings are completely different and these two pages belong to entirely different books (in this example, book 1 and book 9).

Now that we have an idea of what a good identifier might look like, let’s look at
some of the lower-level technical details involved in creating and working with identifiers that align with these expectations.

## Implementation
So far we’ve explored characteristics of identifiers and some of the specifics, but there are quite a few of the deeper technical details we need to formalize, which is the focus of this section. Let’s start by looking at something straightforward and fundamental to an identifier: how big it is.

### Size
How long should a given identifier be? While we could simply say it varies over time
(i.e., the length of the identifier might grow as more are created), that can make
things quite complicated for people using the API who might be storing these identifiers in their databases, so it’s generally a good idea to provide some predictability on the space requirements for these identifiers and simply choose a fixed size for how long they’ll be.

In this case, we have a few different options depending on our needs. Addressing
the simplest option first, we may only need identifiers that are unique across a single resource type. In other words, it might be perfectly fine to have both book 1 and author 1, since we have the different resource types to distinguish between the two 1’s. In this case, we probably only need around 64 bits worth of storage space (similar to using a single 64-bit integer in a relational database like MySQL). Using Crockford’s Base32, we have a total of 32 choices (or 5 bits) per ASCII character, which means we can probably get away with 12 total characters for the identifier (providing 60 bits for our identifier). When serializing (and de-serializing) this, we will need one more character for the checksum digit, meaning 13 characters in total, leading to identifiers like `books/AHM6A83HENMP~` (or `books/ahm6a83henmp~` or `books/ahm6-a83h-enmp~` using lowercase and potential hyphens as separators for readability).

In some other cases, we may need identifiers that are globally unique—not just
across resource types or even across this single API, but across all resources every-
where. To accomplish this, we should probably aim to have at least the same number
of possible identifiers as standard UUIDs (universally unique identifiers), which is a
128-bit ID represented by 32 hexadecimal digits. Since 6 of those bits are reserved for metadata about the ID, this leaves 122 bits for the identifier value. Using Crockford’s Base32, we would need around 24 characters, which would give us a 120-bit identifier. Combine this with one additional checksum digit for a total of 25 characters, leading to identifiers that might look like `books/64s36d-1n6rv-kge9g-c5h66~` (remember, the hyphens are optional and can technically be placed anywhere, and all the letters are case insensitive).

As we’ll learn later when we talk about aliases, we may want to introduce a leading
“0” character to distinguish between identifiers and aliases, which would add one
extra character to our regular IDs. With all that behind us though, it’s time to discuss
an important but subtle (and thus far assumed) issue: who makes IDs.

### Generation
We’ve talked quite a bit about the format and data type that an identifier should take; however, there’s been a running assumption that these are just random identifiers, and we’ve said nothing about how to actually create them. Let’s start by looking at an important aspect of this: origin.

#### ORIGIN
Before we talk about how to generate these identifiers, we should first talk about who should actually create them. In short, it’s worth noting that allowing users of an API to choose their own identifiers is a very dangerous thing and should be avoided.

For starters, this can lead to frustration and confusion when the name has been
used at some point in the past. Since our requirement of permanence 
means identifiers must never be reused (even after being deleted), a user who wants to recreate a resource might be confused by getting an error message about an ID collision when they are certain a resource with that ID doesn’t exist (and it might not exist now, but it did at some point in the past). While this can be mitigated with a sufficiently large set of available IDs, humans are particularly bad at choosing random values from a given set.

Next, when API users want to choose their own identifiers, they tend to make poor
decisions, for example, by putting personally identifiable information into the identifier itself. In other words, someone might create a book with an identifier of `pad(base32-Encode("harry-potter-8"))` (equivalent to `D1GQ4WKS5NR6YX3MCNS2TE05===`), which, obviously, the author would want to keep secret from the world. However, this can be difficult because most systems don’t treat IDs (even Base32-encoded ones) as secret information. Instead, identifiers are commonly treated as opaque, random pieces of data to be used however is most convenient. This means that they’re generally considered safe to store in log files and share with anyone. This includes showing these IDs on big dashboards around the office, highlighting potential errors or statistics for individual resources. If an API allows user-chosen identifiers, there may come a day where a large customer (or a government) demands that some IDs be kept secret, which may be exceptionally difficult (or even impossible) to accomplish.

Finally, one of our last requirements of identifiers is that they are unpredictable. While it’s certainly possible that the users of your API will have a background in cryptography or pseudo-random number generators, as we noted before, that’s generally not the case. As a result, asking users to choose their own identifiers can be problematic. In the best case, it can be annoying if required (“Why can’t you just come up with an ID for me?”), but in the worst case it can be dangerous, even if this is an optional feature. In particular, this creates an opportunity for users to generate predictable identifiers, making them an easy attack target for security mistakes.

#### PSEUDO-RANDOM NUMBER GENERATORS
Just like with most programming problems, we have several different ways to go about generating random identifiers. One option is to use a cryptographically secure random byte generator (e.g., Node.js’s `crypto.randomBytes()` function) and convert that into Crockford’s Base32 (using, for example, Node.js’s `base32-encode` package). Another option would be to use a random choice algorithm to choose a set number of characters from Crockford’s Base32 alphabet. Neither of these is necessarily right or wrong, just different.

The former focuses on the number of bytes involved in the randomly chosen iden-
tifier (choosing an ID as it will be stored in the database) while the latter cares more
about the user-facing identifier (choosing an ID as a user will actually see it). So long
as you do the math ahead of time, knowing how many characters you want your bytes to represent or how many bytes your chosen characters will need reserved in your database, either one is reasonable.

The math itself is pretty simple, since we’re just converting between 8-bit bytes and
5-bit characters. This means that for each byte of data in an ID, the 8 bits of each of
those bytes must be represented by characters capable of holding 5 bits. In short, this means `base32Length == Math.ceil(bytes * 8 / 5)`.

For illustration purposes, let’s look at how to generate a random identifier focused
on bytes-first.

```typescript
const crypto = require('crypto');
const base32Encode = require('base32-encode');
// Here, sizeBytes is the number of bytes in the ID.
function generateId(sizeBytes: number): string {
  const bytes = crypto.randomBytes(sizeBytes);
  return base32Encode(bytes, 'Crockford');
}
```

Now that we know how to generate an ID, we need to be sure that this ID isn’t in use
(and also wasn’t ever in use in the past). Let’s look briefly at how we might do this.

### Tomb-stoning
As we learned in the section about identifier permanence, it’s critical that identifiers
be used no more than one time across the life span of an API. This means that even
after a resource has been deleted, we can’t reuse that same identifier. There are lots of ways to do this, some requiring more storage space than others.

One simple option is to rely on the idea of soft deletion. In this design pattern, rather than actually deleting a resource and its data entirely (“hard deletion”), we could simply mark the resource as deleted. Then, from the perspective of our identifier generation code, we simply continue generating random values until we come across a value that’s not yet taken, checking our database along the way to ensure the ID is actually available. While this pattern can be useful regardless of whether we’re concerned about tomb-stoned identifiers, it suffers from the age-old problem of unpredictable execution time that will statistically only get worse as more and more identifiers are created and the set of available IDs gets used up. That said, with a 120-bit identifier, the key space is about the same size as the number of bacterial cells in existence on the planet. This means that choosing the same one twice is sort of like picking one bacterial cell from all of those on the planet and then randomly picking that exact same one again. In other words, running into a collision should be exceptionally rare.

In cases where relying on the soft deletion pattern doesn’t make sense (perhaps
the data involved is significant and you must purge it for some reason, for example
regulatory requirements), you have lots of other options. For example, you can store
just the identifiers that have been taken in a hash-map somewhere or hold onto a
Bloom filter and add IDs to that filter as they start being used. That said, collisions are still best avoided by using a sufficiently large identifier relative to the number of
resources you’ll be creating and using a reliable and cryptographically secure source
of randomness to generate your identifiers.

### Checksum
As noted in earlier, calculating a checksum is as simple as treating our byte
value as an integer and using the modulo 37 value as the checksum value. This
means we divide the number by 37 and use the remainder as the checksum. Sometimes, however, code speaks a bit louder than words. Note that we’ll rely on the `BigInt` type for handling large integers that might result from a byte buffer of arbitrary length.

```typescript
// Calculating a Base32 checksum value
function calculateChecksum(bytes: Buffer): number {
  // Start by converting the byte buffer into a BigInt value.
  const intValue = BigInt(`0x${bytes.toString('hex')}`);
  // Calculate the checksum value by determining the remainder after dividing by 37.
  return Number(intValue % BigInt(37));
}
```

Additionally, we’ll need a way to encode this checksum value as a string (rather than
just the numeric value). To do this, we can build on the standard Base32 alphabet with five additional characters: `*`, `~`, `#`, `=`, and `U` (this also includes u when parsing the values due to the case insensitivity of Crockford’s Base32). This way, any value that results from our checksum calculation (which will range from 0 to 36) will have a character value to use in the identifier.

```typescript
function getChecksumCharacter(checksumValue: number): string {
  const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ*~$=U';
  // Return the character at position checksumValue
  return alphabet[Math.abs(checksumValue)];
}
```

At this point, you may be wondering, “Okay, so I have a checksum character. Now what?” Quite simply we can append this character to the end of our Base32-encoded identifier when displaying identifiers to users, and when identifiers are provided we can rely on this checksum character being correct. Let’s start by updating the `generateId` function to include the checksum character.

```typescript
const crypto = require('crypto');
const base32Encode = require('base32-encode');
function generateIdWithChecksum(sizeBytes: number): string {
  const bytes = crypto.randomBytes(sizeBytes);
  const checksum = calculateChecksum(bytes);
  // Calculate the checksum and get the correct checksum character.
  const checksumChar = getChecksumCharacter(checksum);
  const encoded = base32Encode(bytes, 'Crockford');
  // Return the Base32 serialized identifier with the checksum character appended.
  return encoded + checksumChar;
}
```

On the other end, we should parse all incoming identifiers as two pieces: the identifier itself and the checksum character. If we check the checksum character and it turns out to be incorrect, that doesn’t mean that the checksum was calculated incorrectly. It actually means that there was probably a typo or other mistake in the identifier itself, and we should reject the identifier as invalid. To see how this might work, the code below implements a `verifyIdentifier` function that returns a Boolean value of whether a given identifier should be considered valid.

```typescript
// Verifying a Base32 identifier based on its checksum value
function verifyId(identifier: string): boolean {
  // Split the identifier into two pieces: the value and the checksum character.
  const value = identifier.substring(0, identifier.length-1);
  const checksumChar = identifier[identifier.length-1];
  // Decode the Base32 value into its raw bytes.
  const buffer = Buffer.from(base32Decode(value, 'Crockford'));
  // Return whether the calculated checksum value is equal to the provided one.
  return (getChecksumCharacter(calculateChecksum(buffer)) == checksumChar);
}
```

Now that we’ve covered how to calculate and verify checksum values, let’s move on to how all of this works from a data store perspective.

### Database storage
For all our talk about not using auto-incrementing integers, most databases out there recommend this and have optimized quite a bit for it, which leads to the obvious question: if we use this newfangled random Base32-encoded identifier, how should we store it so that our databases don’t fall over from exhaustion or confusion?

First, we have to decide what exactly will need to get stored in the database. Obviously the identifier itself will need to be stored, but what about the checksum character? This value (and any other metadata that we may have encoded into the identifier when handing it to users) should not be stored in the database. Instead, we should always calculate that value on the fly as a verification step on incoming IDs (and append it dynamically on outgoing IDs). If we ever have to make changes to the algorithm used in calculating the checksum value, it’ll be a great relief to know we won’t have to go through and rewrite every entry in our database to reflect the new checksum character.

Now that we’ve decided the only piece of data to store is the actual identifier, we
need to consider how exactly we’ll store that. There are lots of different options for
how we store this data, but we’ll discuss three different ones, starting with the simplest: strings.

Many databases (particularly key-value storage systems) are very good at using
string values as identifiers. If you happen to be using one of those, then storing the
identifiers of your resources becomes incredibly simple: you simply store the string
representation of your resource identifier as it appears to your customers (after
removing the checksum character, of course). This is basically as straightforward and
simple as it gets, so if you can get away with this option, go for it. Also keep in mind
that Crockford’s Base32 encoding preserves sorting order, which means that we
shouldn’t have any weirdness where sorting in the database acts differently than sorting on the client side.

Unfortunately, not all databases are as good at storing (and indexing) string values
as others. Further, when storing the string representation of an identifier you’re actually wasting space (since each 8-bit character only represents 5 bits of actual data). With this in mind, we can always go with the lowest level available: storing raw bytes. Many databases are quite good at using raw bytes fields as identifiers. For those types of databases, we can rely on the raw bytes data type (for example, MySQL calls this `BINARY`) for our primary key, enforcing uniqueness constraints and adding indexes that make single-key lookup queries fast and simple.

Finally, if we choose the size of an identifier properly, we can size it so that it will fit
nicely inside a common integer type (e.g., 32 or 64 bits). If possible, this is probably the best option because almost all databases are exceptionally good at storing and indexing numeric values. To do this, we simply take the bytes represented by our identifier and treat them as representing an integer, which we saw how to do when learning how to calculate the checksum value for a given ID (e.g., `byteBuffer.readBigInt64BEInt(0)`). Using an integer as the underlying storage format is likely the most commonly supported option, as it will fit with almost all database systems out there.

### What about UUIDs?
If you’re not familiar with UUIDs, it’s probably safe for you to skip this section. In
short, UUIDs are common 128-bit identifier formats with a relatively long history (the specification, RFC-4122, is dated July 2005). UUIDs are basically a standard identifier format with quite a few handy features such as name spacing, lots of available IDs, and therefore a negligible chance of collisions. We won’t get into all the details of UUIDs, but you may recognize them by their hyphenated format, where they look like the following: `123e4567-e89b-12d3-a456-426655440000`.

If you are aware of what UUIDs are and you’ve read this far and are thinking, “Why
aren’t we just using UUIDs and calling this a day?” then you’re not alone (for one
thing, it would’ve been much faster to just skip this chapter if that were the case). The short answer is that UUIDs are perfectly fine if you need them, but there are three points worth mentioning for why we didn’t replace this entire chapter with the message, “Just use UUIDs.”

First, UUIDs are large (122 total bits of identifier space, 128 bits of data in total),
which is overkill for the most common scenarios. In cases like these, you might want
to use an ID format that is shorter and easier to read if you know you won’t be creating trillions of resources.

Next, UUIDs in their string format are not all that informationally dense since they
rely only on hexadecimal (Base16) notation for transport. In short, this means that
we’re only carrying 4 bits of information per ASCII character, compared to the 5 bits
per character we get by using Base32 encoding. While this might not be important for computers (after all, compression is pretty great these days), when we need to copy and share these over nontechnical means (e.g., share the identifier over the phone), high information density can certainly be a nice benefit.

Finally, UUIDs, by definition, don’t come with their own checksum value. This
means we don’t have a great way to distinguish with certainty between a UUID that is missing versus a UUID that couldn’t possibly have ever existed (and therefore likely has a typographical error present). In cases like this, it would make sense to introduce an additional checksum value to the identifier so that we can tell the difference between these two scenarios, perhaps using a similar method to how Base32 calculates a checksum character.

With all that in mind, it might make sense to use UUID values internally, but still
present a Base32 string as the customer-facing identifier. This allows you to benefit
from all of the features UUIDs provide, such as name spacing (UUID v3 and v5) or
timestamp-based values (UUID v1 and v2), as well as the Base32 feature set, such as
checksum values, readability, and higher information density.

You might generate a Base32-encoded UUID v4 (randomly generated) with a
checksum character.

```typescript
// Generating a random Base32-encoded UUID v4
const base32Encode = require('base32-encode');
const uuid4 = require('uuid/v4');
// In this example, we use the uuid package on NPM.
// Start by allocating a 16-byte buffer to hold the UUID.
function generateBase32EncodedUuid(): string {
  const b = Buffer.alloc(16);
  // Generate the UUID (in this case, a random UUID v4) and store it in the buffer.
  uuid4(null, b);
  // Calculate the checksum and get the right Base37 checksum character.
  const checksum = calculateChecksum(b);
  const checksumChar = getChecksumCharacter(checksum);
// Return the Crockford Base32 encoded value (and the checksum).
  return base32Encode(b, 'Crockford') + checksumChar;
}
```

We might also want to do this if we have a database that is particularly good at storing and indexing UUIDs, rather than storing these as strings, raw bytes, or integers, as we noted earlier.