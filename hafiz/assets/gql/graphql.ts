/* eslint-disable */
import { TypedDocumentNode as DocumentNode } from '@graphql-typed-document-node/core';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  /**
   * The `Naive DateTime` scalar type represents a naive date and time without
   * timezone. The DateTime appears in a JSON response as an ISO8601 formatted
   * string.
   */
  NaiveDateTime: { input: any; output: any; }
};

export enum AccountResult {
  AlreadyRegistered = 'ALREADY_REGISTERED',
  AlreadyRequested = 'ALREADY_REQUESTED',
  InvalidAccount = 'INVALID_ACCOUNT',
  InvalidEmail = 'INVALID_EMAIL'
}

export type AtMessageContent = {
  __typename?: 'AtMessageContent';
  name: Scalars['String']['output'];
  qid: Scalars['String']['output'];
};

export type Bot = {
  __typename?: 'Bot';
  isOnline: Scalars['Boolean']['output'];
};

export type DailyThreadsStatistics = {
  __typename?: 'DailyThreadsStatistics';
  count: Scalars['Int']['output'];
  date: Scalars['NaiveDateTime']['output'];
};

export type FaceMessageContent = {
  __typename?: 'FaceMessageContent';
  id: Scalars['String']['output'];
};

export type Group = Node & {
  __typename?: 'Group';
  gid: Scalars['String']['output'];
  /** The ID of an object */
  id: Scalars['ID']['output'];
  name: Scalars['String']['output'];
};

export type GroupConnection = {
  __typename?: 'GroupConnection';
  edges: Array<GroupEdge>;
  pageInfo: PageInfo;
};

export type GroupEdge = {
  __typename?: 'GroupEdge';
  cursor?: Maybe<Scalars['String']['output']>;
  node: Group;
};

export type ImageMessageContent = {
  __typename?: 'ImageMessageContent';
  blurredUrl: Scalars['String']['output'];
  height: Scalars['Int']['output'];
  url: Scalars['String']['output'];
  width: Scalars['Int']['output'];
};

export type Me = {
  __typename?: 'Me';
  /** Notification message template for the current user */
  notificationMessage?: Maybe<NotificationMessage>;
  perms: Array<Scalars['String']['output']>;
  /** User token for socket usage */
  token?: Maybe<Scalars['String']['output']>;
  /** Current logged-in user */
  user?: Maybe<User>;
};

export type Message = Node & {
  __typename?: 'Message';
  content: Array<MessageContent>;
  /** The ID of an object */
  id: Scalars['ID']['output'];
  sender: User;
  sentAt: Scalars['NaiveDateTime']['output'];
};

export type MessageContent = AtMessageContent | FaceMessageContent | ImageMessageContent | TextMessageContent;

export type Node = {
  /** The ID of the object. */
  id: Scalars['ID']['output'];
};

export type NotificationMessage = Node & {
  __typename?: 'NotificationMessage';
  /** The ID of an object */
  id: Scalars['ID']['output'];
  operator: User;
  template: Scalars['String']['output'];
};

export type NotificationMessageConnection = {
  __typename?: 'NotificationMessageConnection';
  edges: Array<NotificationMessageEdge>;
  pageInfo: PageInfo;
};

export type NotificationMessageEdge = {
  __typename?: 'NotificationMessageEdge';
  cursor?: Maybe<Scalars['String']['output']>;
  node: NotificationMessage;
};

export type PageInfo = {
  __typename?: 'PageInfo';
  /** When paginating forwards, the cursor to continue. */
  endCursor?: Maybe<Scalars['String']['output']>;
  /** When paginating forwards, are there more items? */
  hasNextPage: Scalars['Boolean']['output'];
  /** When paginating backwards, are there more items? */
  hasPreviousPage: Scalars['Boolean']['output'];
  /** When paginating backwards, the cursor to continue. */
  startCursor?: Maybe<Scalars['String']['output']>;
};

export type PinnedMessage = Node & {
  __typename?: 'PinnedMessage';
  content: Scalars['String']['output'];
  /** The ID of an object */
  id: Scalars['ID']['output'];
  operator: User;
  title: Scalars['String']['output'];
  type: PinnedMessageType;
};

export type PinnedMessageConnection = {
  __typename?: 'PinnedMessageConnection';
  edges: Array<PinnedMessageEdge>;
  pageInfo: PageInfo;
};

export type PinnedMessageEdge = {
  __typename?: 'PinnedMessageEdge';
  cursor?: Maybe<Scalars['String']['output']>;
  node: PinnedMessage;
};

export enum PinnedMessageType {
  Alert = 'ALERT',
  Info = 'INFO',
  News = 'NEWS'
}

export type RootMutationType = {
  __typename?: 'RootMutationType';
  cancelUserAccount?: Maybe<User>;
  createBroadcastMessage?: Maybe<Scalars['Boolean']['output']>;
  /** Create or update a notification message template for user */
  createNotificationMessage?: Maybe<NotificationMessage>;
  createPinnedMessage?: Maybe<PinnedMessage>;
  createUserAccount?: Maybe<AccountResult>;
  deletePinnedMessage?: Maybe<PinnedMessage>;
  updateUserRole?: Maybe<User>;
};


export type RootMutationTypeCancelUserAccountArgs = {
  id: Scalars['ID']['input'];
};


export type RootMutationTypeCreateBroadcastMessageArgs = {
  groupId: Scalars['String']['input'];
  message: Scalars['String']['input'];
};


export type RootMutationTypeCreateNotificationMessageArgs = {
  template: Scalars['String']['input'];
};


export type RootMutationTypeCreatePinnedMessageArgs = {
  content: Scalars['String']['input'];
  title: Scalars['String']['input'];
  type: PinnedMessageType;
};


export type RootMutationTypeCreateUserAccountArgs = {
  email: Scalars['String']['input'];
};


export type RootMutationTypeDeletePinnedMessageArgs = {
  id: Scalars['ID']['input'];
};


export type RootMutationTypeUpdateUserRoleArgs = {
  id: Scalars['ID']['input'];
  role: UserRole;
};

export type RootQueryType = {
  __typename?: 'RootQueryType';
  bot: Bot;
  dailyThreadsStatistics: Array<DailyThreadsStatistics>;
  groups: GroupConnection;
  me?: Maybe<Me>;
  node?: Maybe<Node>;
  notificationMessages: NotificationMessageConnection;
  pinnedMessages: PinnedMessageConnection;
  threads: ThreadConnection;
  userActivities: UserActivityConnection;
  users: UserConnection;
};


export type RootQueryTypeGroupsArgs = {
  after?: InputMaybe<Scalars['String']['input']>;
  before?: InputMaybe<Scalars['String']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
};


export type RootQueryTypeNodeArgs = {
  id: Scalars['ID']['input'];
};


export type RootQueryTypeNotificationMessagesArgs = {
  after?: InputMaybe<Scalars['String']['input']>;
  before?: InputMaybe<Scalars['String']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
};


export type RootQueryTypePinnedMessagesArgs = {
  after?: InputMaybe<Scalars['String']['input']>;
  before?: InputMaybe<Scalars['String']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
};


export type RootQueryTypeThreadsArgs = {
  after?: InputMaybe<Scalars['String']['input']>;
  before?: InputMaybe<Scalars['String']['input']>;
  filter?: InputMaybe<ThreadFilter>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
};


export type RootQueryTypeUserActivitiesArgs = {
  after?: InputMaybe<Scalars['String']['input']>;
  before?: InputMaybe<Scalars['String']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
};


export type RootQueryTypeUsersArgs = {
  after?: InputMaybe<Scalars['String']['input']>;
  before?: InputMaybe<Scalars['String']['input']>;
  first?: InputMaybe<Scalars['Int']['input']>;
  last?: InputMaybe<Scalars['Int']['input']>;
};

export type TextMessageContent = {
  __typename?: 'TextMessageContent';
  text: Scalars['String']['output'];
};

export type Thread = Node & {
  __typename?: 'Thread';
  group: Group;
  /** The ID of an object */
  id: Scalars['ID']['output'];
  messages: Array<Message>;
  owner: User;
  postedAt: Scalars['NaiveDateTime']['output'];
};

export type ThreadConnection = {
  __typename?: 'ThreadConnection';
  edges: Array<ThreadEdge>;
  pageInfo: PageInfo;
};

export type ThreadEdge = {
  __typename?: 'ThreadEdge';
  cursor?: Maybe<Scalars['String']['output']>;
  node: Thread;
};

export type ThreadFilter = {
  /** Filtering by a specific day */
  date?: InputMaybe<Scalars['NaiveDateTime']['input']>;
  /** Filtering by a group gid */
  group?: InputMaybe<Scalars['String']['input']>;
  /** Filtering by a user qid */
  user?: InputMaybe<Scalars['String']['input']>;
};

export type User = Node & {
  __typename?: 'User';
  /** The ID of an object */
  id: Scalars['ID']['output'];
  name: Scalars['String']['output'];
  qid: Scalars['String']['output'];
  registered: Scalars['Boolean']['output'];
  role: UserRole;
  /** User statistics including counts of messages, threads and followers */
  statistics: UserStatistics;
};

export type UserActivity = Node & {
  __typename?: 'UserActivity';
  /** The ID of an object */
  id: Scalars['ID']['output'];
  location: Scalars['String']['output'];
  mouseX: Scalars['Float']['output'];
  mouseY: Scalars['Float']['output'];
  offlineAt: Scalars['NaiveDateTime']['output'];
  user: User;
};

export type UserActivityConnection = {
  __typename?: 'UserActivityConnection';
  edges: Array<UserActivityEdge>;
  pageInfo: PageInfo;
};

export type UserActivityEdge = {
  __typename?: 'UserActivityEdge';
  cursor?: Maybe<Scalars['String']['output']>;
  node: UserActivity;
};

export type UserConnection = {
  __typename?: 'UserConnection';
  edges: Array<UserEdge>;
  pageInfo: PageInfo;
};

export type UserEdge = {
  __typename?: 'UserEdge';
  cursor?: Maybe<Scalars['String']['output']>;
  node: User;
};

export enum UserRole {
  Admin = 'ADMIN',
  User = 'USER'
}

export type UserStatistics = {
  __typename?: 'UserStatistics';
  chats: Scalars['Int']['output'];
  followers: Scalars['Int']['output'];
  threads: Scalars['Int']['output'];
};

export type CreateUserAccountMutationMutationVariables = Exact<{
  email: Scalars['String']['input'];
}>;


export type CreateUserAccountMutationMutation = { __typename?: 'RootMutationType', createUserAccount?: AccountResult | null };


export const CreateUserAccountMutationDocument = {"kind":"Document","definitions":[{"kind":"OperationDefinition","operation":"mutation","name":{"kind":"Name","value":"CreateUserAccountMutation"},"variableDefinitions":[{"kind":"VariableDefinition","variable":{"kind":"Variable","name":{"kind":"Name","value":"email"}},"type":{"kind":"NonNullType","type":{"kind":"NamedType","name":{"kind":"Name","value":"String"}}}}],"selectionSet":{"kind":"SelectionSet","selections":[{"kind":"Field","name":{"kind":"Name","value":"createUserAccount"},"arguments":[{"kind":"Argument","name":{"kind":"Name","value":"email"},"value":{"kind":"Variable","name":{"kind":"Name","value":"email"}}}]}]}}]} as unknown as DocumentNode<CreateUserAccountMutationMutation, CreateUserAccountMutationMutationVariables>;