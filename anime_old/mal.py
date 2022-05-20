import datetime as dt
import pandas as pd
import numpy as np
import re


# duration; rating, licensors, producers

# opening_themes, ending_themes, broadcast, source, title: en, jp, synonims; image_url, trailer_url

cols = ['mal_id', 'title', 'type', 'status', 'started', 'finished', 'duration', 'episodes',
        'favorites', 'score', 'rank', 'scored_by']

skipped_cols = ['members', 'popularity']

ignored_cols = ['synopsis', 'rating', 'genres', 'related', 'licensors', 'producers', 'studios']

useless_cols = ['aired', 'airing', 'premiered']

missing_cols = ['background']


def get_database():
    db = pd.read_csv('data/anime_complete_old.csv')

    for i, col in enumerate(['started', 'finished']):
        db[col] = db.aired.str.split(' to ').str[i]
        db[col] = pd.to_datetime(db[col].apply(format))
    
    db = db[cols]
    
    db.rename(columns={'favorites': 'fav', 'scored_by': 'scored'}, inplace=True)

    db.score.replace(-1.0, np.nan, inplace=True)
    db.scored.replace(-1.0, np.nan, inplace=True)
    db['rank'].replace(-1.0, np.nan, inplace=True)
    
    airing_types = {'Currently Airing': 'A', 'Finished Airing': 'CP', 'Not yet aired': 'P'}
    db['status'] = db.apply(lambda row: airing_types[row['status']], axis=1)

    db.sort_values('scored', ascending=False, inplace=True)
    db['pop'] = range(1, db.shape[0] + 1)

    db['value'] = db.apply(lambda row: row['rank'] + row['pop'], axis=1)
    
    db = db.astype({'type': 'category', 'status': 'category', 'scored': 'Int64', 'rank': 'Int64', 'value': 'Int64'})

    db.sort_index(inplace=True)

    db = db.set_index('mal_id')
    return db


def merge(mal, db):
    mal = mal.rename(columns={'score': 'nota'})
    df = pd.merge(mal, db, left_on='mal_id', right_on='mal_id', how='outer')
    df.title_x.fillna(df.title_y, inplace=True)

    df.type_x = df.type_x.cat.set_categories(db.type.cat.categories)
    df.type_x.fillna(df.type_y, inplace=True)

    df.A_ep.fillna(df.episodes, inplace=True)
    
    df.A_st = df.A_st.cat.set_categories(df.status.cat.categories)
    df.A_st.fillna(df.status, inplace=True)
    
    df.A_start.fillna(df.started, inplace=True)
    df.A_end.fillna(df.finished, inplace=True)

    df.rename(columns={'title_x': 'title', 'type_x': 'type'}, inplace=True)

    df.drop(columns=['title_y', 'type_y', 'episodes', 'status', 'started', 'finished'], inplace=True)

    df.W_ep.fillna(0, inplace=True)
    df.days.fillna(0, inplace=True)
    df.fav.fillna(0, inplace=True)

    df = df.astype({'W_ep': 'int', 'days': 'int', 'A_ep': 'int', 'fav': 'int', 'pop': 'Int64'})

    df.W_st = df.W_st.cat.add_categories('N')

    df.W_st.fillna('N', inplace=True)

    return df


def format(x):
    if pd.isna(x) or x=='?' or x=='Not available':
        return pd.NA

    if re.match('[0-9]{4}', x):
        return dt.datetime.strptime(x, '%Y')
    
    if re.match('[A-Z][a-z]{2}, [0-9]{4}', x):
        return dt.datetime.strptime(x, '%b, %Y')
    
    if re.match('[A-Z][a-z]{2} [0-9]+, [0-9]{4}', x):
        return dt.datetime.strptime(x, '%b %d, %Y')
    
    return pd.NA


def make_clickable(val):
    return '<a target="_blank" href="https://myanimelist.net/anime/{}">{}</a>'.format(val, val)


def format_date(date):
    if pd.isna(date):
        return date
    return date.strftime('%Y-%m-%d')


def print_format(df, links=0):
    df = df.copy()
    df.fav = df.fav.map(format_num)
    df.scored = df.scored.map(format_num)

    if links == 0:
        return df
    
    formatter = {'mal_id': make_clickable,
                 'score': '{:.3}'}
    for date in ['A_start', 'A_end', 'W_start', 'W_end']:
        formatter[date] = format_date
    
    return df.reset_index().head(links).style.hide_index().format(formatter)


def format_num(n):
    if not isinstance(n, int):
        return n
    if n < 1_000:
        return n
    if n < 100_000:
        return str(round(n/10**3, 6-len(str(n)))) + "k"
    if n < 1_000_000:
        return str(int(round(n/10**3))) + "k"
    else:
        return str(round(n/10**6, 2)) + "M"


def filter_prequel(df):
    db = pd.read_csv('data/anime_list.csv')

    db = db.set_index('mal_id')

    db['prequel'] = db.related.str.contains('Prequel')

    df = df.copy()

    df['prequel'] = db['prequel']

    return df[df.prequel != True].drop(columns='prequel')
