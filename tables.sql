/*
This table is used to store the current state (latest exported epoch) of all validators
It also acts as a lookup-table to store the index-pubkey association
In order to save db space we only use the unique validator index in all other tables
In the future it is better to replace this table with an in memory cache (redis)
*/
drop table if exists validators;
create table validators
(
    validatorindex             int    not null,
    pubkey                     bytea  not null,
    withdrawableepoch          bigint not null,
    withdrawalcredentials      bytea  not null,
    balance                    bigint not null,
    effectivebalance           bigint not null,
    slashed                    bool   not null,
    activationeligibilityepoch bigint not null,
    activationepoch            bigint not null,
    exitepoch                  bigint not null,
    lastattestationslot        bigint,
    name                       varchar(40),
    primary key (validatorindex)
);
create index idx_validators_pubkey on validators (pubkey);

drop table if exists validator_set;
create table validator_set
(
    epoch                      int    not null,
    validatorindex             int    not null,
    withdrawableepoch          bigint not null,
    withdrawalcredentials      bytea  not null,
    effectivebalance           bigint not null,
    slashed                    bool   not null,
    activationeligibilityepoch bigint not null,
    activationepoch            bigint not null,
    exitepoch                  bigint not null,
    primary key (validatorindex, epoch)
);

drop table if exists validator_performance;
create table validator_performance
(
    validatorindex  int    not null,
    balance         bigint not null,
    performance1d   bigint not null,
    performance7d   bigint not null,
    performance31d  bigint not null,
    performance365d bigint not null,
    primary key (validatorindex)
);
create index idx_validator_performance_balance on validator_performance (balance);
create index idx_validator_performance_performance1d on validator_performance (performance1d);
create index idx_validator_performance_performance7d on validator_performance (performance7d);
create index idx_validator_performance_performance31d on validator_performance (performance31d);
create index idx_validator_performance_performance365d on validator_performance (performance365d);

drop table if exists proposal_assignments;
create table proposal_assignments
(
    epoch          int not null,
    validatorindex int not null,
    proposerslot   int not null,
    status         int not null, /* Can be 0 = scheduled, 1 executed, 2 missed */
    primary key (epoch, validatorindex, proposerslot)
);

drop table if exists attestation_assignments;
create table attestation_assignments
(
    epoch          int not null,
    validatorindex int not null,
    attesterslot   int not null,
    committeeindex int not null,
    status         int not null, /* Can be 0 = scheduled, 1 executed, 2 missed */
    primary key (epoch, validatorindex, attesterslot, committeeindex)
);
create index idx_attestation_assignments_validatorindex on attestation_assignments (validatorindex);

drop table if exists validator_balances;
create table validator_balances
(
    epoch            int    not null,
    validatorindex   int    not null,
    balance          bigint not null,
    effectivebalance bigint not null,
    primary key (validatorindex, epoch)
);
create index idx_validator_balances_epoch on validator_balances (epoch);


drop table if exists validatorqueue_activation;
create table validatorqueue_activation
(
    index     int   not null,
    publickey bytea not null,
    primary key (index, publickey)
);

drop table if exists validatorqueue_exit;
create table validatorqueue_exit
(
    index     int   not null,
    publickey bytea not null,
    primary key (index, publickey)
);

drop table if exists epochs;
create table epochs
(
    epoch                   int    not null,
    blockscount             int    not null default 0,
    proposerslashingscount  int    not null,
    attesterslashingscount  int    not null,
    attestationscount       int    not null,
    depositscount           int    not null,
    voluntaryexitscount     int    not null,
    validatorscount         int    not null,
    averagevalidatorbalance bigint not null,
    totalvalidatorbalance   bigint not null,
    finalized               bool,
    eligibleether           bigint,
    globalparticipationrate float,
    votedether              bigint,
    primary key (epoch)
);

drop table if exists blocks;
create table blocks
(
    epoch                  int   not null,
    slot                   int   not null,
    blockroot              bytea not null,
    parentroot             bytea not null,
    stateroot              bytea not null,
    signature              bytea not null,
    randaoreveal           bytea,
    graffiti               bytea,
    graffiti_text          text  null,
    eth1data_depositroot   bytea,
    eth1data_depositcount  int   not null,
    eth1data_blockhash     bytea,
    proposerslashingscount int   not null,
    attesterslashingscount int   not null,
    attestationscount      int   not null,
    depositscount          int   not null,
    voluntaryexitscount    int   not null,
    proposer               int   not null,
    status                 text  not null,
    primary key (slot, blockroot)
);
create index idx_blocks_proposer on blocks (proposer);

drop table if exists blocks_proposerslashings;
create table blocks_proposerslashings
(
    block_slot         int    not null,
    block_index        int    not null,
    proposerindex      int    not null,
    header1_slot       bigint not null,
    header1_parentroot bytea  not null,
    header1_stateroot  bytea  not null,
    header1_bodyroot   bytea  not null,
    header1_signature  bytea  not null,
    header2_slot       bigint not null,
    header2_parentroot bytea  not null,
    header2_stateroot  bytea  not null,
    header2_bodyroot   bytea  not null,
    header2_signature  bytea  not null,
    primary key (block_slot, block_index)
);

drop table if exists blocks_attesterslashings;
create table blocks_attesterslashings
(
    block_slot                   int       not null,
    block_index                  int       not null,
    attestation1_indices         integer[] not null,
    attestation1_signature       bytea     not null,
    attestation1_slot            bigint    not null,
    attestation1_index           int       not null,
    attestation1_beaconblockroot bytea     not null,
    attestation1_source_epoch    int       not null,
    attestation1_source_root     bytea     not null,
    attestation1_target_epoch    int       not null,
    attestation1_target_root     bytea     not null,
    attestation2_indices         integer[] not null,
    attestation2_signature       bytea     not null,
    attestation2_slot            bigint    not null,
    attestation2_index           int       not null,
    attestation2_beaconblockroot bytea     not null,
    attestation2_source_epoch    int       not null,
    attestation2_source_root     bytea     not null,
    attestation2_target_epoch    int       not null,
    attestation2_target_root     bytea     not null,
    primary key (block_slot, block_index)
);

drop table if exists blocks_attestations;
create table blocks_attestations
(
    block_slot      int   not null,
    block_index     int   not null,
    aggregationbits bytea not null,
    validators      int[] not null,
    signature       bytea not null,
    slot            int   not null,
    committeeindex  int   not null,
    beaconblockroot bytea not null,
    source_epoch    int   not null,
    source_root     bytea not null,
    target_epoch    int   not null,
    target_root     bytea not null,
    primary key (block_slot, block_index)
);
create index idx_blocks_attestations_beaconblockroot on blocks_attestations (beaconblockroot);
create index idx_blocks_attestations_source_root on blocks_attestations (source_root);
create index idx_blocks_attestations_target_root on blocks_attestations (target_root);

drop table if exists blocks_deposits;
create table blocks_deposits
(
    block_slot            int    not null,
    block_index           int    not null,
    proof                 bytea[],
    publickey             bytea  not null,
    withdrawalcredentials bytea  not null,
    amount                bigint not null,
    signature             bytea  not null,
    primary key (block_slot, block_index)
);

drop table if exists blocks_voluntaryexits;
create table blocks_voluntaryexits
(
    block_slot     int   not null,
    block_index    int   not null,
    epoch          int   not null,
    validatorindex int   not null,
    signature      bytea not null,
    primary key (block_slot, block_index)
);

drop table if exists network_liveness;
create table network_liveness
(
    ts                     timestamp without time zone,
    headepoch              int not null,
    finalizedepoch         int not null,
    justifiedepoch         int not null,
    previousjustifiedepoch int not null,
    primary key (ts)
);

drop table if exists graffitiwall;
create table graffitiwall
(
    x         int  not null,
    y         int  not null,
    color     text not null,
    slot      int  not null,
    validator int  not null,
    primary key (x, y)
);

drop table if exists eth1_deposits;
create table eth1_deposits
(
    tx_hash                bytea                       not null,
    tx_input               bytea                       not null,
    tx_index               int                         not null,
    block_number           int                         not null,
    block_ts               timestamp without time zone not null,
    from_address           bytea                       not null,
    publickey              bytea                       not null,
    withdrawal_credentials bytea                       not null,
    amount                 bigint                      not null,
    signature              bytea                       not null,
    merkletree_index       bytea                       not null,
    removed                bool                        not null,
    valid_signature        bool                        not null,
    primary key (tx_hash)
);
create index idx_eth1_deposits on eth1_deposits (publickey);

drop table if exists users;
create table users (
    id                      serial                      not null unique,
    password                character varying(256)      not null,
    email                   character varying(100)      not null unique,
    email_confirmed         bool                        not null default 'f',
    email_confirmation_hash character varying(40)                unique,
    email_confirmation_ts   timestamp without time zone,
    password_reset_hash     character varying(40),
    password_reset_ts       timestamp without time zone,
    register_ts             timestamp without time zone,
    primary key (id, email)
);

drop table if exists users_subscriptions;
create table users_subscriptions (
    id              serial                      not null,
    user_id         int                         not null,
    event_name      character varying(100)      not null,
    event_filter    text                        not null default '',
    last_sent_ts    timestamp without time zone,
    last_sent_epoch int,
    created_ts      timestamp without time zone not null,
    created_epoch   int                         not null,
    primary key (user_id, event_name, event_filter),
    constraint fk_user_id foreign key(user_id) references users(id) on delete cascade
);

drop table if exists users_validators_tags;
create table users_validators_tags (
    user_id             int                    not null,
    validator_publickey bytea                  not null,
    tag                 character varying(100) not null,
    primary key (user_id, validator_publickey, tag),
    constraint fk_user_id foreign key(user_id) references users(id) on delete cascade
);

drop table if exists mails_sent;
create table mails_sent (
    email character varying(100)      not null,
    ts    timestamp without time zone not null,
    cnt   int                         not null,
    primary key (email, ts)
);
