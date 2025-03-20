import { GraphQLScalarType, Kind } from "graphql";

export const DateScalar = new GraphQLScalarType({
  name: "Date",
  description: "A custom scalar that handles date values",
  serialize(value) {
    // Convert outgoing Date to string
    return value instanceof Date ? value.toISOString() : null;
  },
  parseValue(value) {
    // Convert incoming string to Date
    return new Date(value);
  },
  parseLiteral(ast) {
    if (ast.kind === Kind.STRING) {
      return new Date(ast.value); // Convert hard-coded AST string to Date
    }
    return null; // Invalid hard-coded value (not a string)
  },
});

// Custom Time Scalar
export const TimeScalar = new GraphQLScalarType({
  name: "Time",
  description: "A time string in the format HH:mm:ss",
  parseValue(value) {
    return value; // value from the client
  },
  serialize(value) {
    return value; // value sent to the client
  },
  parseLiteral(ast) {
    if (ast.kind === Kind.STRING) {
      return ast.value; // ast value is always in string format
    }
    return null; // Invalid hard-coded value (not a string)
  },
});

// Custom DateTime Scalar
export const DateTimeScalar = new GraphQLScalarType({
  name: "DateTime",
  description: "A date and time string in ISO 8601 format",
  parseValue(value) {
    return new Date(value); // value from the client
  },
  serialize(value) {
    return value.toISOString(); // value sent to the client
  },
  parseLiteral(ast) {
    if (ast.kind === Kind.STRING) {
      return new Date(ast.value); // ast value is always in string format
    }
    return null; // Invalid hard-coded value (not a string)
  },
});

// Function to format date to ISO 8601 format
const formatDateToISO = (date) => {
  return date.toISOString(); // Converts to ISO 8601 format
};

// Function to parse date from PostgreSQL format
const parseDateFromPostgres = (value) => {
  return new Date(value); // Converts PostgreSQL timestamp string to Date
};

// Custom CustomDateTime Scalar
export const CustomDateTimeScalar = new GraphQLScalarType({
  name: "CustomDateTime",
  description:
    "A custom date and time string in the format YYYY-MM-DD HH:mm:ss.ssssss",
  parseValue(value) {
    return parseDateFromPostgres(value); // Convert from client input to Date
  },
  serialize(value) {
    return formatDateToISO(value); // Convert from Date to ISO 8601 format
  },
  parseLiteral(ast) {
    if (ast.kind === Kind.STRING) {
      return parseDateFromPostgres(ast.value); // Convert from string literal to Date
    }
    return null; // Invalid hard-coded value (not a string)
  },
});
